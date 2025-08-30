import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:binayak_pharmacy/blocs/medicine_bloc.dart';
import 'package:binayak_pharmacy/blocs/medicine_event.dart';
import 'package:binayak_pharmacy/blocs/medicine_state.dart';
import 'package:binayak_pharmacy/data/models/medicine_model.dart';
import 'mocks.mocks.dart';

void main() {
  group('MedicineBloc', () {
    late MockDatabaseHelper mockDbHelper;
    late MockDatabase mockDatabase;
    late MedicineBloc medicineBloc;

    setUp(() {
      mockDbHelper = MockDatabaseHelper();
      mockDatabase = MockDatabase();
      medicineBloc = MedicineBloc(mockDbHelper);
    });

    test('initial state is MedicineLoading', () {
      expect(medicineBloc.state, isA<MedicineLoading>());
    });

    blocTest<MedicineBloc, MedicineState>(
      'emits [MedicineLoading, MedicineLoaded] when LoadMedicines is added',
      build: () {
        when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('medicines')).thenAnswer((_) async => []);
        return medicineBloc;
      },
      act: (bloc) => bloc.add(LoadMedicines()),
      expect: () => [
        isA<MedicineLoading>(),
        isA<MedicineLoaded>(),
      ],
    );

    blocTest<MedicineBloc, MedicineState>(
      'emits [MedicineAddSuccess] when AddMedicine is added',
      build: () {
        when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.insert('medicines', any)).thenAnswer((_) async => 1);
        return medicineBloc;
      },
      act: (bloc) => bloc.add(AddMedicine(
        Medicine(
          name: 'Test Medicine',
          quantity: 10,
          price: 9.99,
          expiryDate: DateTime.now(),
        ),
      )),
      expect: () => [
        isA<MedicineAddSuccess>(),
      ],
    );

    blocTest<MedicineBloc, MedicineState>(
      'emits [MedicineUpdateSuccess] when UpdateMedicine is added',
      build: () {
        when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.update('medicines', any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'))).thenAnswer((_) async => 1);
        return medicineBloc;
      },
      act: (bloc) => bloc.add(UpdateMedicine(
        Medicine(
          id: 1,
          name: 'Updated Medicine',
          quantity: 20,
          price: 19.99,
          expiryDate: DateTime.now(),
        ),
      )),
      expect: () => [
        isA<MedicineUpdateSuccess>(),
      ],
    );

    blocTest<MedicineBloc, MedicineState>(
      'emits [MedicineDeleteSuccess] when DeleteMedicine is added',
      build: () {
        when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete('medicines', where: anyNamed('where'), whereArgs: anyNamed('whereArgs'))).thenAnswer((_) async => 1);
        return medicineBloc;
      },
      act: (bloc) => bloc.add(DeleteMedicine(1)),
      expect: () => [
        isA<MedicineDeleteSuccess>(),
      ],
    );
  });
}
