import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/hive_drafts.dart';
import '../models/models.dart';
import '../repositories/demo_repository.dart';
import '../repositories/membership_repository.dart';
import '../repositories/supabase_repository.dart';

final hiveStoreProvider = Provider<HiveDraftStore>((ref) => HiveDraftStore());

final repositoryProvider = Provider<MembershipRepository>((ref) {
  return SupabaseRepository(hive: ref.watch(hiveStoreProvider));
});

final repoInitProvider = FutureProvider<MembershipRepository>((ref) async {
  final repo = ref.watch(repositoryProvider);
  await repo.initialize();
  return repo;
});

final connectionStatusProvider = Provider<String>((ref) {
  final repo = ref.watch(repositoryProvider);
  if (repo is SupabaseRepository) return repo.connectionLabel;
  if (repo is DemoRepository) return 'Demo local';
  return 'Unknown';
});

final connectionConnectedProvider = Provider<bool>((ref) {
  final repo = ref.watch(repositoryProvider);
  if (repo is SupabaseRepository) return repo.isConnected;
  return false;
});

final sessionProvider = NotifierProvider<SessionNotifier, DemoUser?>(SessionNotifier.new);

class SessionNotifier extends Notifier<DemoUser?> {
  @override
  DemoUser? build() {
    final repo = ref.watch(repositoryProvider);
    void onChange() => state = repo.currentUser;
    repo.addListener(onChange);
    ref.onDispose(() => repo.removeListener(onChange));
    return repo.currentUser;
  }

  Future<void> login(DemoUser user) async {
    await ref.read(repositoryProvider).loginAs(user);
    state = user;
  }

  Future<void> logout() async {
    await ref.read(repositoryProvider).logout();
    state = null;
  }
}

final dataTickProvider = NotifierProvider<DataTickNotifier, int>(DataTickNotifier.new);

class DataTickNotifier extends Notifier<int> {
  @override
  int build() {
    final repo = ref.watch(repositoryProvider);
    void onChange() => state = state + 1;
    repo.addListener(onChange);
    ref.onDispose(() => repo.removeListener(onChange));
    return 0;
  }
}


final pendingLoginUserProvider =
    NotifierProvider<PendingLoginNotifier, DemoUser?>(PendingLoginNotifier.new);

class PendingLoginNotifier extends Notifier<DemoUser?> {
  @override
  DemoUser? build() => null;
  void setUser(DemoUser? user) => state = user;
}
