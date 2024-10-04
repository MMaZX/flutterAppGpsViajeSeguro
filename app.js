const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io')(server, { cors: { origin: "*" } });
const axios = require('axios');
require('dotenv').config();
require('use-strict');
var admin = require("firebase-admin");
const { initializeApp } = require("firebase/app");
const mysql = require('mysql2');
const { log } = require('console');

const pool = mysql.createPool({
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '',
    database: 'viaje_Seguro'
});

const JWT_SECRET = process.env.JWT_SECRET;
const APP_URL = process.env.APP_URL_NODE;
const port = process.env.PORT_WS ?? 3000;

const chairsConnected = [];
const connectedUsers = [];
io.on("connection", (socket) => {
    console.log("WS Connected");

    // Evento para actualizar la localización de un usuario
    socket.on('updateLocation', (userContent) => {
        const { dni, totalIncidencias, numAsientos, numAsientosActivos, placa } = userContent;
        const dniInt = parseInt(dni, 10);
        const index = connectedUsers.findIndex(user => user.id === dniInt);
        if (index !== -1) {
            if (totalIncidencias !== undefined) {
                connectedUsers[index].totalIncidencias = totalIncidencias;
            }

            if (numAsientos !== undefined) {
                connectedUsers[index].numAsientos = numAsientos;
            }

            if (numAsientosActivos !== undefined) {
                connectedUsers[index].numAsientosActivos = numAsientosActivos;
            }

            if (placa !== undefined) {
                connectedUsers[index].placa = placa;
            }
            console.log("Updated user:", connectedUsers[index]);
            io.emit("allUsersConnected", connectedUsers);
        } else {
            console.error("No se encuentra el dni correcto.", dniInt);
        }
    });

    // Evento para manejar solicitudes
    socket.on('sendSolicitud', (solicitudParameter) => {
        const { dni, numAsientos, dnipasajero } = solicitudParameter;
        const user = findUserById(dni);
        const userPasajero = findUserById(dnipasajero);
        const roomId = user ? user.socketId : null;
        const socketName = 'solicitud';
        if (roomId) {
            io.emit(socketName, {
                'value': true,
                'message': `Tienes un nuevo viaje, requieren ${numAsientos} asientos, su nombre es ${userPasajero.nombreConductor}, con DNI ${userPasajero.id}. ¿Qué deseas hacer?`,
                'dni': dni,
                'dnipasajero': dnipasajero,
                'user': user,
                'numAsientosRequest': numAsientos
            });
        } else {
            io.emit(socketName, {
                'value': false,
                'message': 'Usuario no encontrado',
                'dni': null,
                'dnipasajero': dnipasajero,
                'user': null,
                'numAsientosRequest': numAsientos
            });
        }
    });

    // Evento para registrar usuarios
    socket.on('register', (userInfo) => {
        const { id, rol, lat, log, nombreConductor, totalIncidencias, numAsientos, numAsientosActivos, placa } = userInfo;
        // console.log(userInfo);
        const user = new UserModel(id, lat, log, rol, socket.id, totalIncidencias, numAsientos, numAsientosActivos, placa, nombreConductor);
        const existingUserIndex = connectedUsers.findIndex(user => user.id === id);

        if (existingUserIndex !== -1) {
            connectedUsers[existingUserIndex] = user;
        } else {
            connectedUsers.push(user);
        }

        // console.log(connectedUsers);
        io.emit("allUsersConnected", connectedUsers);
    });

    socket.on('estadoSolicitudRespuesta', (datos) => {
        const { dni, estado } = datos;
        const user = findUserById(dni);
        const roomId = user ? user.socketId : null;

        
        if (roomId) {
            io.to(roomId).emit('esperandoPasajero', {
                estado: estado, 
                dni: dni,
            });
        } else {
            console.log(`Usuario con DNI ${dni} no encontrado`);
        }
    });




    // Evento para manejar la desconexión
    socket.on("disconnect", () => {
        console.log("WS Disconnected");
        // Elimina el usuario desconectado
        const index = connectedUsers.findIndex((user) => user.socketId === socket.id);
        if (index !== -1) {
            const removedUser = connectedUsers.splice(index, 1)[0];
            console.log(`Usuario desconectado: ${removedUser.id}`);
            // Emitir la lista actualizada
            io.emit("allUsersConnected", connectedUsers);
        } else {
            console.warn("Usuario no encontrado en la lista de conectados.");
        }
    });

    // Evento para capturar cualquier evento
    // socket.onAny((event, ...args) => {
    //     console.log(`Evento recibido: ${event}`, args);
    // });


});

app.get('/', (req, res) => {
    res.send("Hello, this WS server is running!");
});

server.listen(port, () => {
    console.log(`WS server is running on port ${port}!`);
});


function UserModel(id, lat, log, rol, socketId, totalIncidencias, numAsientos, numAsientosActivos, placa, nombreConductor) {
    if (typeof id !== 'number') throw new Error('ID debe ser de tipo numérico');
    this.id = id;
    this.lat = lat;
    this.log = log;
    this.rol = rol;
    this.socketId = socketId;
    this.totalIncidencias = totalIncidencias || 0;
    this.numAsientos = numAsientos || 0;
    this.numAsientosActivos = numAsientosActivos || 0;
    this.placa = placa || '';
    this.nombreConductor = nombreConductor || '';
}


// class UserModel {
//     constructor(id, lat, log, rol, socketId, totalIncidencias = 0, numAsientos = 0, numAsientosActivos = 0, placa = '', nombreConductor = '') {
//         if (typeof id !== 'number') throw new Error('ID debe ser de tipo numérico');
//         this.id = id;
//         this.lat = lat;
//         this.log = log;
//         this.rol = rol;
//         this.socketId = socketId;
//         this.totalIncidencias = totalIncidencias;
//         this.numAsientos = numAsientos;
//         this.numAsientosActivos = numAsientosActivos;
//         this.placa = placa;
//         this.nombreConductor = nombreConductor;
//     }
// }

// Función para buscar un usuario por ID
function findUserById(dni) {
    return connectedUsers.find(user => user.id == dni);
}

// Función para buscar un usuario por socketId
function findUserBySocketId(socketId) {
    return connectedUsers.find(user => user.socketId == socketId);
}