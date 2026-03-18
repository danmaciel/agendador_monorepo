
 import 'package:flutter/material.dart';
class GraficoWidget extends StatelessWidget {
  final Map<String, dynamic>? chartData;

  const GraficoWidget( {super.key,  required this.chartData});

  @override
  Widget build(BuildContext context) {
    return renderizar(context, chartData);
  }

   Widget renderizar(BuildContext context, Map<String, dynamic>? chartData) {
     if (chartData == null || chartData.isEmpty) {
       return Card(
           elevation: 4,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
           child: const SizedBox(
             height: 150,
             width: double.infinity,
             child: Center(
               child: Text('Sem dados para o gráfico.',
                   style: TextStyle(color: Colors.grey, fontSize: 14)),
             ),
           ),
         );
     }

     final sortedKeys = chartData.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
     final counts = sortedKeys.map((key) => (chartData[key] as num).toDouble()).toList();
     final keys = sortedKeys.map((key) => (chartData[key]).toString()).toList();
     final maxCount = counts.reduce((a, b) => a > b ? a : b);
     final safeMax = maxCount == 0 ? 1.0 : maxCount;

     return Card(
       elevation: 4,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
           children: [
             const Text('Agendamentos por Dia', style: TextStyle(color: Colors.grey)),
             const SizedBox(height: 20),
             SizedBox(
               height: 150,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: List.generate(sortedKeys.length, (index) {
                   final heightFactor = counts[index] / safeMax;
                   return Column(
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: [
                       Text(keys[index], style: TextStyle(fontSize: 12)),
                       AnimatedContainer(
                         duration: const Duration(milliseconds: 800),
                         width: 20,
                         height: 110.0 * heightFactor,
                         decoration: BoxDecoration(
                           color: Theme.of(context).primaryColor,
                           borderRadius: BorderRadius.circular(4),
                         ),
                       ),
                       const SizedBox(height: 8),
                       Text(sortedKeys[index], style: const TextStyle(fontSize: 10)),
                     ],
                   );
                 }),
               ),
             ),
           ],
         ),
       ),
     );
   }


 }