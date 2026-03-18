import 'package:flutter/material.dart';

class AgendamentoStatusBadge {

  static Container getBadge(String status){

    Color color;
    switch (status.toUpperCase()) {
      case 'APROVADO':
        color = Colors.green;
        break;
      case 'REJEITADO':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}