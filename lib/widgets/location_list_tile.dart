import '../pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    super.key,
    required this.location,
    required this.press,
  });

  final String location;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: press,
          horizontalTitleGap: 0,
          leading: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.gps_fixed_sharp),
          ),
          title: Text(
            location,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(
          height: 2,
          thickness: 2,
          color: secondaryColor5LightTheme,
        ),
      ],
    );
  }
}
