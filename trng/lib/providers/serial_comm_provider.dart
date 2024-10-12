import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:typed_data';
import 'dart:async';

class SerialCommProvider with ChangeNotifier {
  late SerialPort _serialPort;
  late SerialPortReader _reader;
  final StreamController<Uint8List> _receivedDataController = StreamController<Uint8List>();

  Stream<Uint8List> get _receivedData => _receivedDataController.stream;

  // Custom mapping function
  String _mapByteToString(int byte) {
    switch (byte) {
      case 6:
        return '1';
      case 0:
        return '0';
      // Add more cases as needed
      default:
        return byte.toString();
    }
  }

  Stream<String> get receivedData => _receivedData.map((data) {
    return data.map(_mapByteToString).join(' ');
  });

  void addReceivedData(Uint8List data) {
    _receivedDataController.add(data);
  }

  @override
  void dispose() {
    _receivedDataController.close();
    super.dispose();
  }

  Future<void> connect(String portName) async {
    _serialPort = SerialPort(portName);
    _serialPort.config.baudRate = 9600; // Set baud rate to 9600
    _serialPort.config.bits = 8;
    _serialPort.config.stopBits = 1;
    _serialPort.config.parity = 0;

    if (_serialPort.openReadWrite()) {
      print('Connected to $portName at 9600 baud rate');
      _reader = SerialPortReader(_serialPort);
      _reader.stream.listen((data) {
        final receivedString = data.map((byte) => byte == 6 ? 1 : 0).toList();
        print('Raw data received: $data'); // Debugging: Print raw data
        print('Decoded string: ${receivedString.toString()}'); // Debugging: Print decoded string
        _receivedDataController.add(data);
        notifyListeners();
      });
    } else {
      print('Failed to connect to $portName');
    }
  }

  Stream<Uint8List> get receivedDataStream {
    // Replace with your actual stream source
    return _reader.stream;
  }

  void disconnect() {
    _serialPort.close();
    print('Disconnected');
  }

  void sendData(String data) {
    final bytes = Uint8List.fromList(data.codeUnits);
    _serialPort.write(bytes);
    print('Data sent: $data');
  }
}