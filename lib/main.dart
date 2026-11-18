import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/crime_explorer/data/repositories/incident_repository_impl.dart';
import 'features/crime_explorer/data/services/police_data_service.dart';
import 'features/crime_explorer/data/services/postcode_service.dart';
import 'features/crime_explorer/domain/repositories/incident_repository.dart';
import 'features/crime_explorer/presentation/cubit/crime_cubit.dart';
import 'features/crime_explorer/presentation/screens/crime_explorer_screen.dart';

void main() {
  final api = ApiClient();
  final repository = IncidentRepositoryImpl(
    postcodeService: PostcodeService(api),
    policeService: PoliceDataService(api),
  );
  runApp(StreetLevelApp(repository: repository));
}

class StreetLevelApp extends StatelessWidget {
  const StreetLevelApp({super.key, required this.repository});

  final IncidentRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CrimeCubit(repository),
      child: MaterialApp(
        title: 'Street Watch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const CrimeExplorerScreen(),
      ),
    );
  }
}
