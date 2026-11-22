import 'package:supabase/supabase.dart';

Future<Map<String, dynamic>> cadastrarVeiculo(
  SupabaseClient cliente,
  String marca,
  String modelo,
  int ano,
  double valor,
  int quilometragem,
) async {
  final resultado = await cliente
      .from('veiculos')
      .insert({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'valor': valor,
        'quilometragem': quilometragem,
      })
      .select()
      .single();

  return Map<String, dynamic>.from(resultado);
}

Future<List<Map<String, dynamic>>> listarVeiculos(
  SupabaseClient cliente,
) async {
  final resultado = await cliente
      .from('veiculos')
      .select()
      .order('id', ascending: true);

  return List<Map<String, dynamic>>.from(resultado);
}

Future<Map<String, dynamic>?> atualizarVeiculo(
  SupabaseClient cliente,
  int id,
  String marca,
  String modelo,
  int ano,
  double valor,
  int quilometragem,
) async {
  final resultado = await cliente
      .from('veiculos')
      .update({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'valor': valor,
        'quilometragem': quilometragem,
      })
      .eq('id', id)
      .select()
      .maybeSingle();

  if (resultado == null) return null;
  return Map<String, dynamic>.from(resultado);
}

Future<Map<String, dynamic>?> excluirVeiculo(
  SupabaseClient cliente,
  int id,
) async {
  final resultado = await cliente
      .from('veiculos')
      .delete()
      .eq('id', id)
      .select()
      .maybeSingle();

  if (resultado == null) return null;
  return Map<String, dynamic>.from(resultado);
}
