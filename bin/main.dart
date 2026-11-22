import 'dart:io';

import 'package:supabase/supabase.dart';

import '../lib/conexao.dart';
import '../lib/veiculos.dart';

String lerTexto(String mensagem) {
  stdout.write(mensagem);
  return stdin.readLineSync() ?? '';
}

String? lerMarcaOuModelo(String mensagem, int limite, String campo) {
  final valor = lerTexto(mensagem).trim();
  if (valor.isEmpty) {
    print('$campo não pode ficar vazio.');
    return null;
  }
  if (valor.length > limite) {
    print('$campo deve ter no máximo $limite caracteres.');
    return null;
  }
  return valor;
}

int? lerAno() {
  final entrada = lerTexto('Ano: ').trim();
  final ano = int.tryParse(entrada);
  final anoAtual = DateTime.now().year;
  if (ano == null || ano < 1900 || ano > anoAtual) {
    print('Ano inválido. Informe um inteiro entre 1900 e $anoAtual.');
    return null;
  }
  return ano;
}

double? lerValor() {
  final entrada = lerTexto('Valor: ').trim();
  if (!RegExp(r'^\d+(?:[.,]\d{1,2})?$').hasMatch(entrada)) {
    print('Valor inválido. Use um número positivo com até duas casas decimais, sem separador de milhar.');
    return null;
  }
  final valor = double.tryParse(entrada.replaceAll(',', '.'));
  if (valor == null || !valor.isFinite || valor <= 0 || valor >= 10000000000) {
    print('Valor inválido. Deve ser maior que zero e menor que 10000000000.');
    return null;
  }
  return valor;
}

int? lerQuilometragem() {
  final entrada = lerTexto('Quilometragem: ').trim();
  final km = int.tryParse(entrada);
  if (km == null || km < 0) {
    print('Quilometragem inválida. Informe um inteiro maior ou igual a zero.');
    return null;
  }
  return km;
}

int? lerId() {
  final entrada = lerTexto('ID do veículo: ').trim();
  final id = int.tryParse(entrada);
  if (id == null || id <= 0) {
    print('ID inválido. Informe um número inteiro positivo.');
    return null;
  }
  return id;
}

void mostrarVeiculo(Map<String, dynamic> veiculo) {
  final valor = (veiculo['valor'] as num).toStringAsFixed(2);
  print('ID: ${veiculo['id']} | Marca: ${veiculo['marca']} | Modelo: ${veiculo['modelo']}');
  print('Ano: ${veiculo['ano']} | Valor: R\$ $valor | Quilometragem: ${veiculo['quilometragem']} km');
}

void mostrarMenu() {
  print('\n========== CADASTRO DE VEÍCULOS ==========');
  print('1 - Cadastrar veículo');
  print('2 - Listar veículos');
  print('3 - Atualizar veículo');
  print('4 - Excluir veículo');
  print('0 - Sair');
}

Future<void> cadastrar(SupabaseClient cliente) async {
  final marca = lerMarcaOuModelo('Marca: ', 50, 'Marca');
  if (marca == null) return;
  final modelo = lerMarcaOuModelo('Modelo: ', 100, 'Modelo');
  if (modelo == null) return;
  final ano = lerAno();
  if (ano == null) return;
  final valor = lerValor();
  if (valor == null) return;
  final km = lerQuilometragem();
  if (km == null) return;

  final veiculo = await cadastrarVeiculo(cliente, marca, modelo, ano, valor, km);
  print('Veículo cadastrado!');
  mostrarVeiculo(veiculo);
}

Future<void> listar(SupabaseClient cliente) async {
  final veiculos = await listarVeiculos(cliente);
  if (veiculos.isEmpty) {
    print('Nenhum veículo cadastrado.');
    return;
  }
  for (final veiculo in veiculos) {
    mostrarVeiculo(veiculo);
    print('------------------------------------------');
  }
}

Future<void> atualizar(SupabaseClient cliente) async {
  final id = lerId();
  if (id == null) return;
  final marca = lerMarcaOuModelo('Nova marca: ', 50, 'Marca');
  if (marca == null) return;
  final modelo = lerMarcaOuModelo('Novo modelo: ', 100, 'Modelo');
  if (modelo == null) return;
  final ano = lerAno();
  if (ano == null) return;
  final valor = lerValor();
  if (valor == null) return;
  final km = lerQuilometragem();
  if (km == null) return;

  final veiculo = await atualizarVeiculo(cliente, id, marca, modelo, ano, valor, km);
  if (veiculo == null) {
    print('Nenhum veículo encontrado com o ID informado.');
    return;
  }
  print('Veículo atualizado!');
  mostrarVeiculo(veiculo);
}

Future<void> excluir(SupabaseClient cliente) async {
  final id = lerId();
  if (id == null) return;
  final confirmacao = lerTexto('Confirma a exclusão? S/N: ').trim();
  if (confirmacao == 'N' || confirmacao == 'n') {
    print('Exclusão cancelada.');
    return;
  }
  if (confirmacao != 'S' && confirmacao != 's') {
    print('Resposta inválida. Exclusão não realizada.');
    return;
  }

  final veiculo = await excluirVeiculo(cliente, id);
  if (veiculo == null) {
    print('Nenhum veículo encontrado com o ID informado.');
    return;
  }
  print('Veículo excluído!');
  print('ID: ${veiculo['id']} | ${veiculo['marca']} ${veiculo['modelo']}');
}

Future<void> main() async {
  SupabaseClient? cliente;
  try {
    cliente = await conectar();
    var executando = true;

    while (executando) {
      mostrarMenu();
      final opcao = lerTexto('O que deseja fazer? ').trim();

      try {
        switch (opcao) {
          case '1':
            await cadastrar(cliente);
            break;
          case '2':
            await listar(cliente);
            break;
          case '3':
            await atualizar(cliente);
            break;
          case '4':
            await excluir(cliente);
            break;
          case '0':
            print('Sistema encerrado.');
            executando = false;
            break;
          default:
            print('Opção inválida. Tente novamente.');
        }
      } catch (erro) {
        print('Não foi possível concluir a operação: $erro');
      }
    }
  } catch (erro) {
    print('Erro ao iniciar o sistema: $erro');
  } finally {
    cliente?.dispose();
  }
}
