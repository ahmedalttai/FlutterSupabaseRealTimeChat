
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'errorContainer.dart';

Widget ChatImage({required BuildContext,required String imageSrc, required Function onTap}) {

  return OutlinedButton(onPressed: () {},
      child: Image.network(
        imageSrc,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: ( ctx, Widget child, ImageChunkEvent? loadingProgress){
          if(loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            width: 200,
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.red,
                value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ?
                loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
              ),
            ),
          );
        },
        errorBuilder: (context,object,stackTrace) => errorContainer(),
      )
  );
}