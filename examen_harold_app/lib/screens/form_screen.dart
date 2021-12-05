import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:examen_harold_app/components/loader_component.dart';
import 'package:examen_harold_app/helpers/api_helper.dart';
import 'package:examen_harold_app/models/finals.dart';
import 'package:examen_harold_app/models/response.dart';
import 'package:examen_harold_app/models/token.dart';
import 'package:examen_harold_app/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormScreen extends StatefulWidget {
  final Token token;

  FormScreen({required this.token});

  @override
  _FormScreenState createState() => _FormScreenState();
}


class _FormScreenState extends State<FormScreen> {
   bool _showLoader = false;
   late Finals _finals;
   bool _changeTextButon = true;

  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;
  TextEditingController _emailController = TextEditingController();

  String _theBest = '';
  String _theBestError = '';
  bool _theBestShowError = false;
  TextEditingController _theBestController = TextEditingController();

  String _theWorst = '';
  String _theWorstError = '';
  bool _theWorstShowError = false;
  TextEditingController _theWorstController = TextEditingController();

  String _remarks = '';
  String _remarksError = '';
  bool _remarksShowError = false;
  TextEditingController _remarksController = TextEditingController();

  int _qualification = 0;
  IconData? _selectedIcon;
  double _initialRating = 0;
  late double _rating;
  bool _isRTLMode = false;
  bool _isVertical = false;
  int _ratingBarMode = 1;

  @override
  void initState() {
    super.initState();
    _rating = _initialRating;
    _getFinals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encuesta'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showEmail(),
                _showBest(),
                _showWorst(),
                _showRemarks(),
                _showRating(),
                _showButtons(),
              ],
            ),
          ),
          _showLoader
              ? LoaderComponent(
                  text: 'Por favor espere...',
                )
              : Container(),
        ],
      )
    );
  }


  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Ingresa email...',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          suffixIcon: Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }


  Widget _showBest() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _theBestController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Ingresa lo que mas te gusto...',
          labelText: 'Lo que mas te gusto',
          errorText: _theBestShowError ? _theBestError : null,
          suffixIcon: Icon(Icons.thumb_up_alt),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _theBest = value;
        },
      ),
    );
  }

  Widget _showWorst() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _theWorstController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Ingresa lo que menos te gusto...',
          labelText: 'Lo que menos te gusto',
          errorText: _theWorstShowError ? _theWorstError : null,
          suffixIcon: Icon(Icons.thumb_down_alt),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _theWorst = value;
        },
      ),
    );
  }


  Widget _showRemarks() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _remarksController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Ingresa un comentario...',
          labelText: 'Comentarios Generales',
          errorText: _remarksShowError ? _remarksError : null,
          suffixIcon: Icon(Icons.bookmark),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _remarks = value;
        },
      ),
    );
  }


  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
       child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _showRegisterButton(),
              SizedBox(width: 20,),
              _showLogout(),
            ],
          ),
        ],
      ),
    );
  }


  Widget _showRegisterButton() {
    return Expanded(
      child: ElevatedButton(
        
        child: _changeTextButon ?  Text('Registrar Encuesta') : Text('Actualizar Encuesta'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFF120E43);
          }),
        ),
        onPressed: () => _register(),
      ),
    );
  }


  Widget _showLogout() {
    return Expanded(
      child: ElevatedButton(
        
        child: Text('Cerrar Session'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFF120E43);
          }),
        ),
        onPressed: () => _logOut(),
      ),
    );
  }


  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', false);
    await prefs.setString('userBody', '');

    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => LoginScreen()
      )
    ); 
  }


   void _register() async {
    if (!_validateFields()) {
      return;
    }

    _addRecord();
    }


  bool _validateFields() {
    bool isValid = true;

    if (_theBest.isEmpty) {
      isValid = false;
      _theBestShowError = true;
      _theBestError = 'Debes ingresar al menos lo que mas te gusto.';
    } else {
      _theBestShowError = false;
    }

    if (_theWorst.isEmpty) {
      isValid = false;
      _theWorstShowError = true;
      _theWorstError = 'Debes ingresar al menos lo que menos te gusto.';
    } else {
      _theWorstShowError = false;
    }

    if (_remarks.isEmpty) {
      isValid = false;
      _remarksShowError = true;
      _remarksError = 'Debes ingresar al menos un comentario general.';
    } else {
      _remarksShowError = false;
    }

    if (_email.isEmpty) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email.';
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email válido.';
    } else {
      _emailShowError = false;
    }

   
    setState(() {});
    return isValid;
  }



  void _addRecord() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estes conectado a internet.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    
    Map<String, dynamic> request = {
      'email': _email,
      'qualification': _rating.toInt(),
      'theBest': _theBest,
      'theWorst': _theWorst,
      'remarks': _remarks,
    };

    Response response = await ApiHelper.post(
      '/api/Finals/', 
      request, 
      widget.token
    );

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }else{
        await showAlertDialog(
          context: context,
          title: 'Exitoso',
          message: 'Encuesta guardada exitosamente',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }
  }



  Future<Null> _getFinals() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'Verifica que estes conectado a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    Response response = await ApiHelper.getFinals(widget.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: response.message,
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    setState(() {
      _finals = response.result;
       if(_finals != null){
        _emailController.text = _finals.email;
        _remarksController.text = _finals.remarks;
        _theBestController.text = _finals.theBest;
        _theWorstController.text = _finals.theWorst;
        _rating = _finals.qualification.toDouble();
        _initialRating =  _finals.qualification.toDouble();
        _changeTextButon = false;
        _email = _finals.email;
        _remarks = _finals.remarks;
        _theBest = _finals.theBest;
        _theWorst = _finals.theWorst;
      }
    });
  }



  Widget _showRating(){
     return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 40.0,
                  ),
                  _heading('Calificacion'),
                  _ratingBar(_ratingBarMode),
                  SizedBox(height: 20.0),
                ]
              )
      )      
    );
  }

  Widget _heading(String text) => Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 24.0,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
  );

  Widget _ratingBar(int mode) {
    switch (mode) {
      case 1:
        return RatingBar.builder(
          initialRating: _initialRating,
          minRating: 1,
          direction: _isVertical ? Axis.vertical : Axis.horizontal,
          allowHalfRating: true,
          unratedColor: Colors.amber.withAlpha(50),
          itemCount: 5,
          itemSize: 50.0,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            _selectedIcon ?? Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
          updateOnDrag: true,
        );
      default:
        return Container();
    }
  }
}