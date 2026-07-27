import 'package:flutter/material.dart';

import '../../../customers/models/vehicle.dart';

/// Ícone representativo de cada tipo de veículo, usado nos cartões da
/// garagem do cliente.
IconData vehicleTypeIcon(VehicleType type) {
  return switch (type) {
    VehicleType.car => Icons.directions_car_outlined,
    VehicleType.motorcycle => Icons.two_wheeler_outlined,
    VehicleType.truck => Icons.local_shipping_outlined,
    VehicleType.utility => Icons.airport_shuttle_outlined,
    VehicleType.jetSki => Icons.pool_outlined,
    VehicleType.aircraft => Icons.flight_outlined,
  };
}
