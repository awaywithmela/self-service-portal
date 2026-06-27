import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_client.dart';

final networkClientProvider = Provider<NetworkClient>((ref) => NetworkClient());
