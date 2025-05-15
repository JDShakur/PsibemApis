import 'package:flutter/material.dart';
import 'package:psibem/widget/progress_bar.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;
  const LoadingDialog({super.key, this.message});


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularProgress(),
          SizedBox( height: 10,),
          Text('${message!}, Aguarde...')
        ],
      ),
    );
  }
}
