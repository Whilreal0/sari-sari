import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/store_repository.dart';
import '../services/user_service.dart';

// Events
abstract class StoreEvent {}
class FetchStores extends StoreEvent {
  final String ownerId;
  FetchStores(this.ownerId);
}
class AddStore extends StoreEvent {
  final String name;
  final String ownerId;
  final String? plan;
  AddStore(this.name, this.ownerId, {this.plan});
}
class DeleteStore extends StoreEvent {
  final String storeId;
  final String ownerId;
  DeleteStore(this.storeId, this.ownerId);
}
class RenameStore extends StoreEvent {
  final String storeId;
  final String newName;
  final String ownerId;
  RenameStore(this.storeId, this.newName, this.ownerId);
}

// States
abstract class StoreState {}
class StoreInitial extends StoreState {}
class StoreLoading extends StoreState {}
class StoreLoaded extends StoreState {
  final List<Map<String, dynamic>> stores;
  StoreLoaded(this.stores);
}
class StoreError extends StoreState {
  final String message;
  StoreError(this.message);
}

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepository storeRepository;
  StoreBloc(this.storeRepository) : super(StoreInitial()) {
    on<FetchStores>((event, emit) async {
      emit(StoreLoading());
      try {
        final stores = await storeRepository.getStoresByOwner(event.ownerId);
        
        // If no stores exist, create a default store with admin's plan
        if (stores.isEmpty) {
          // Get admin's subscription data to determine plan
          final subscriptionData = await UserService.getSubscriptionData();
          final adminPlan = subscriptionData?['plan'] ?? 'free';
          
          await storeRepository.addStore('Store 1', event.ownerId, plan: adminPlan);
          final updatedStores = await storeRepository.getStoresByOwner(event.ownerId);
          emit(StoreLoaded(updatedStores));
        } else {
          emit(StoreLoaded(stores));
        }
      } catch (e) {
        emit(StoreError(e.toString()));
      }
    });
    on<AddStore>((event, emit) async {
      try {
        await storeRepository.addStore(event.name, event.ownerId, plan: event.plan ?? 'free');
        final stores = await storeRepository.getStoresByOwner(event.ownerId);
        emit(StoreLoaded(stores));
      } catch (e) {
        emit(StoreError(e.toString()));
      }
    });
    on<DeleteStore>((event, emit) async {
      try {
        await storeRepository.deleteStore(event.storeId);
        final stores = await storeRepository.getStoresByOwner(event.ownerId);
        emit(StoreLoaded(stores));
      } catch (e) {
        emit(StoreError(e.toString()));
      }
    });
    on<RenameStore>((event, emit) async {
      try {
        await storeRepository.renameStore(event.storeId, event.newName);
        final stores = await storeRepository.getStoresByOwner(event.ownerId);
        emit(StoreLoaded(stores));
      } catch (e) {
        emit(StoreError(e.toString()));
      }
    });
  }
} 
