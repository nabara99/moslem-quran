import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/reciter.dart';
import '../providers/audio_provider.dart';

class ReciterSelectionScreen extends StatelessWidget {
  const ReciterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reciters = Reciter.getAllReciters();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Pilih Qari'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              final reciter = reciters[index];
              final isSelected = audioProvider.selectedReciter.id == reciter.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () async {
                    await audioProvider.selectReciter(reciter);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Qari dipilih: ${reciter.name}'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.primaryBlue,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.primaryGradient
                                : LinearGradient(
                                    colors: [
                                      AppColors.textSecondary.withValues(alpha: 0.1),
                                      AppColors.textSecondary.withValues(alpha: 0.05),
                                    ],
                                  ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              reciter.name.substring(0, 1),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reciter.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reciter.arabicName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (reciter.description != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  reciter.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primaryBlue,
                            size: 28,
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            color: AppColors.textSecondary.withValues(alpha: 0.3),
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
