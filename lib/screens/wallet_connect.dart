import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:land_registration/providers/MetamaskProvider.dart';
import 'package:land_registration/constant/loadingScreen.dart';
import 'package:land_registration/screens/registerUser.dart';
import 'package:land_registration/widget/footer.dart';
import 'package:land_registration/widget/header.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../providers/LandRegisterModel.dart';
import '../constant/utils.dart';

class CheckPrivateKey extends StatefulWidget {
  final String val;
  const CheckPrivateKey({Key? key, required this.val}) : super(key: key);

  @override
  _CheckPrivateKeyState createState() => _CheckPrivateKeyState();
}

class _CheckPrivateKeyState extends State<CheckPrivateKey> {
  String privatekey = "";
  String errorMessage = "";
  bool isDesktop = false;
  double width = 590;
  bool _isObscure = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController keyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<LandRegisterModel>(context);
    var model2 = Provider.of<MetaMaskProvider>(context);
    width = MediaQuery.of(context).size.width;

    if (width > 600) {
      isDesktop = true;
      width = 590;
    }
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
      // Top Header
      const Material(
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.only(left: 150.0, top: 15, right: 50, bottom: 15),
          child: HeaderWidget(),
        ),
      ),
      SizedBox(
        height: 50,
      ),
      Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/auth2.svg',
              height: 280.0,
              width: 520.0,
              allowDrawingOutsideViewBox: true,
            ),
            const Text('You can enter private key of your wallet'),
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: keyController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter private key';
                      }
                      return null;
                    },
                    obscureText: _isObscure,
                    onChanged: (val) {
                      privatekey = val;
                    },
                    decoration: InputDecoration(
                      suffixIcon: MaterialButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () async {
                          final clipPaste =
                              await Clipboard.getData(Clipboard.kTextPlain);
                          keyController.text = clipPaste?.text ?? '';
                          privatekey = keyController.text;
                          setState(() {});
                        },
                        child: const Text(
                          "Paste",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      suffix: IconButton(
                          iconSize: 20,
                          constraints: const BoxConstraints.tightFor(
                              height: 15, width: 15),
                          padding: const EdgeInsets.all(0),
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          }),
                      border: const OutlineInputBorder(),
                      labelText: 'Private Key',
                      hintText: 'Enter Your Private Key',
                    ),
                  ),
                ),
              ),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            CustomButton(
              'Continue',
              isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        print("Form validated");
                        privateKey = privatekey;
                        connectedWithMetamask = false;
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          await model.initiateSetup();
                          print("Setup initiated");

                          if (widget.val == "owner") {
                            bool temp = await model.isContractOwner(privatekey);
                            print("Is contract owner: $temp");
                            if (!temp) {
                              setState(() {
                                errorMessage = "You are not authorized";
                              });
                            } else {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/contractowner');
                            }
                          } else if (widget.val == "RegisterUser") {
                            bool temp = await model.isUserregistered();
                            print("Is user registered: $temp");
                            if (temp) {
                              setState(() {
                                errorMessage = "You are already registered";
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterUser(),
                                ),
                              );
                            }
                          } else if (widget.val == "LandInspector") {
                            bool temp = await model.isLandInspector(privatekey);
                            print("Is land inspector: $temp");
                            if (!temp) {
                              setState(() {
                                errorMessage = "You are not authorized";
                              });
                            } else {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/landinspector');
                            }
                          } else if (widget.val == "UserLogin") {
                            bool temp = await model.isUserregistered();
                            print("Is user registered for login: $temp");
                            if (!temp) {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/registeruser');
                            } else {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed('/user');
                            }
                          }
                        } catch (e) {
                          print("Error: $e");
                          showToast(
                            "Something went wrong",
                            context: context,
                            backgroundColor: Colors.red,
                          );
                        }
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
            ),
            if (isLoading) spinkitLoader else Container(),
          ],
        ),
      ),
      SizedBox(
        height: 50,
      ),
      const Material(
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.only(left: 150.0, top: 15, right: 50, bottom: 15),
          child: FooterWidget(),
        ),
      ),
    ])));
  }
}
