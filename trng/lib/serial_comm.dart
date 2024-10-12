import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:typed_data';

class SerialCommProvider with ChangeNotifier {
  late SerialPort _serialPort;
  late SerialPortReader _reader;
  String _receivedData = '';
  String get receivedData => _receivedData;

  Future<void> connect(String portName) async {
    _serialPort = SerialPort(portName);
    _serialPort.config.baudRate = 9600; // Set baud rate to 9600
    _serialPort.config.bits = 8;
    _serialPort.config.stopBits = 1;
    _serialPort.config.parity = 0;

    if (_serialPort.openReadWrite()) {
      //print('Connected to $portName at 9600 baud rate');
      _reader = SerialPortReader(_serialPort);
      _reader.stream.listen((data) {
        final receivedString = String.fromCharCodes(data);
        //print('Raw data received: $data'); // Debugging: Print raw data
        //print('Decoded string: $receivedString'); // Debugging: Print decoded string
        _receivedData += receivedString;
        notifyListeners();
      });
    } else {
      //print('Failed to connect to $portName');
    }
  }

  void disconnect() {
    _serialPort.close();
    //print('Disconnected');
  }

  void sendData(String data) {
    final bytes = Uint8List.fromList(data.codeUnits);
    _serialPort.write(bytes);
    //print('Data sent: $data');
  }
}