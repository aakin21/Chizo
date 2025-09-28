import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/prediction_service.dart';
import '../l10n/app_localizations.dart';

class WinRatePredictionDialog extends StatefulWidget {
  final UserModel winner;
  final VoidCallback onPredictionComplete;

  const WinRatePredictionDialog({
    super.key,
    required this.winner,
    required this.onPredictionComplete,
  });

  @override
  State<WinRatePredictionDialog> createState() => _WinRatePredictionDialogState();
}

class _WinRatePredictionDialogState extends State<WinRatePredictionDialog> {
  int? selectedRange;
  bool isSubmitting = false;

  // Win rate aralıkları - sadece 10'ar aralık
  final List<Map<String, dynamic>> winRateRanges = [
    {'min': 0, 'max': 10, 'label': '0-10%'},
    {'min': 11, 'max': 20, 'label': '11-20%'},
    {'min': 21, 'max': 30, 'label': '21-30%'},
    {'min': 31, 'max': 40, 'label': '31-40%'},
    {'min': 41, 'max': 50, 'label': '41-50%'},
    {'min': 51, 'max': 60, 'label': '51-60%'},
    {'min': 61, 'max': 70, 'label': '61-70%'},
    {'min': 71, 'max': 80, 'label': '71-80%'},
    {'min': 81, 'max': 90, 'label': '81-90%'},
    {'min': 91, 'max': 100, 'label': '91-100%'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: widget.winner.matchPhotos != null && widget.winner.matchPhotos!.isNotEmpty
                      ? NetworkImage(widget.winner.matchPhotos!.first['photo_url'])
                      : null,
                  child: widget.winner.matchPhotos == null || widget.winner.matchPhotos!.isEmpty
                      ? const Icon(Icons.person, size: 25)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.winner.username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.predictWinRateTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Açıklama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.blue, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.correctPredictionReward,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.wrongPredictionNoCoin,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Win rate aralıkları
            Text(
              AppLocalizations.of(context)!.selectWinRateRange,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Aralık seçimi
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: winRateRanges.asMap().entries.map((entry) {
                final index = entry.key;
                final range = entry.value;
                final isSelected = selectedRange == index;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRange = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          range['label'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isSubmitting ? null : () {
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (selectedRange != null && !isSubmitting) ? _submitPrediction : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Tahmin Et'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPrediction() async {
    if (selectedRange == null) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final range = winRateRanges[selectedRange!];
      final actualWinRate = widget.winner.winRate;
      
      // Prediction service'ini kullan
      final result = await PredictionService.submitPrediction(
        winnerId: widget.winner.id,
        minRange: range['min'],
        maxRange: range['max'],
        actualWinRate: actualWinRate,
      );
      
      if (result['success']) {
        // Sonuç dialog'unu göster
        await _showResultDialog(
          result['is_correct'], 
          range, 
          result['actual_winrate'],
          result['reward_coins'],
        );
        
        // Callback'i çağır
        widget.onPredictionComplete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.predictionSaveError)),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _showResultDialog(bool isCorrect, Map<String, dynamic> range, double actualWinRate, int rewardCoins) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sonuç emoji
            Text(
              isCorrect ? '🎉' : '😔',
              style: const TextStyle(fontSize: 80),
            ),
            
            const SizedBox(height: 16),
            
            // Başlık
            Text(
              isCorrect ? AppLocalizations.of(context)!.congratulations : AppLocalizations.of(context)!.wrongPrediction,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Açıklama
            Text(
              isCorrect 
                  ? AppLocalizations.of(context)!.correctPredictionMessage
                  : AppLocalizations.of(context)!.wrongPredictionMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Detaylar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Tahminin: ${range['label']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.actualRate(actualWinRate),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (isCorrect)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.earnedOneCoin,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Result dialog'u kapat
              Navigator.pop(context); // Prediction dialog'u kapat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCorrect ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }
}
