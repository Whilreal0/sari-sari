import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/invite_repository.dart';

// EVENTS
abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}
class InviteManagerRequested extends ProfileEvent {
  final String email;
  final String storeId;
  final String invitedBy;
  InviteManagerRequested({
    required this.email,
    required this.storeId,
    required this.invitedBy,
  });
}

// STATES
abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;
  ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];

  String get plan => profile['plan'] ?? 'free';
  String? get subscriptionEnd => profile['subscription_end'];
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
class InviteSuccess extends ProfileState {}
class InviteFailure extends ProfileState {
  final String error;
  InviteFailure(this.error);
}

// BLOC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final InviteRepository inviteRepository;
  ProfileBloc({required this.inviteRepository}) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          emit(ProfileError('Not logged in'));
          return;
        }
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        emit(ProfileLoaded(data));
      } catch (e) {
        emit(ProfileError('Failed to load profile'));
      }
    });
    on<InviteManagerRequested>((event, emit) async {
      try {
        await inviteRepository.inviteManager(
          email: event.email,
          storeId: event.storeId,
          invitedBy: event.invitedBy,
        );
        emit(InviteSuccess());
      } catch (e) {
        emit(InviteFailure(e.toString()));
      }
    });
  }
} 