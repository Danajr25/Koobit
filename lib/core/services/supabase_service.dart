import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service for database and auth operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  /// Singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase with project credentials
  /// Call this in main() before runApp()
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
    _client = Supabase.instance.client;
  }

  /// Get Supabase client
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  /// Get auth client
  GoTrueClient get auth => client.auth;

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current session
  Session? get currentSession => auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // ==================== AUTH METHODS ====================

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await auth.resetPasswordForEmail(email);
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    return await auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ==================== DATABASE METHODS ====================

  /// Get data from a table
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String? columns,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    // Build the base query
    var baseQuery = client.from(table).select(columns ?? '*');

    // Apply filters
    if (filters != null) {
      for (final entry in filters.entries) {
        baseQuery = baseQuery.eq(entry.key, entry.value);
      }
    }

    // Apply ordering, limit, and offset in sequence
    dynamic query = baseQuery;
    
    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 10) - 1);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single row by ID
  Future<Map<String, dynamic>?> selectById(
    String table,
    String id, {
    String? columns,
  }) async {
    final response = await client
        .from(table)
        .select(columns ?? '*')
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Insert data into a table
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await client.from(table).insert(data).select().single();
    return response;
  }

  /// Insert multiple rows
  Future<List<Map<String, dynamic>>> insertMany(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    final response = await client.from(table).insert(data).select();
    return List<Map<String, dynamic>>.from(response);
  }

  /// Update data in a table
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Update with custom filter
  Future<List<Map<String, dynamic>>> updateWhere(
    String table,
    Map<String, dynamic> data,
    Map<String, dynamic> filters,
  ) async {
    var query = client.from(table).update(data);

    filters.forEach((key, value) {
      query = query.eq(key, value);
    });

    final response = await query.select();
    return List<Map<String, dynamic>>.from(response);
  }

  /// Delete data from a table
  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  /// Delete with custom filter
  Future<void> deleteWhere(
    String table,
    Map<String, dynamic> filters,
  ) async {
    var query = client.from(table).delete();

    filters.forEach((key, value) {
      query = query.eq(key, value);
    });

    await query;
  }

  /// Upsert (insert or update)
  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data, {
    String? onConflict,
  }) async {
    final response = await client
        .from(table)
        .upsert(data, onConflict: onConflict)
        .select()
        .single();
    return response;
  }

  /// Execute RPC (stored procedure)
  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    return await client.rpc(functionName, params: params);
  }

  // ==================== STORAGE METHODS ====================

  /// Upload file to storage
  Future<String> uploadFile(
    String bucket,
    String path,
    List<int> fileBytes, {
    String? contentType,
  }) async {
    await client.storage.from(bucket).uploadBinary(
      path,
      fileBytes as dynamic,
      fileOptions: FileOptions(contentType: contentType),
    );
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Download file from storage
  Future<List<int>> downloadFile(String bucket, String path) async {
    final response = await client.storage.from(bucket).download(path);
    return response;
  }

  /// Delete file from storage
  Future<void> deleteFile(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }

  /// Get public URL for a file
  String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  // ==================== REALTIME METHODS ====================

  /// Subscribe to realtime changes on a table
  RealtimeChannel subscribeToTable(
    String table, {
    required void Function(PostgresChangePayload payload) onInsert,
    void Function(PostgresChangePayload payload)? onUpdate,
    void Function(PostgresChangePayload payload)? onDelete,
    String? filter,
  }) {
    var channel = client.channel('public:$table');

    channel = channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: table,
      filter: filter != null ? PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: filter.split('=')[0],
        value: filter.split('=')[1],
      ) : null,
      callback: onInsert,
    );

    if (onUpdate != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        callback: onUpdate,
      );
    }

    if (onDelete != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        callback: onDelete,
      );
    }

    channel.subscribe();
    return channel;
  }

  /// Unsubscribe from realtime channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}
