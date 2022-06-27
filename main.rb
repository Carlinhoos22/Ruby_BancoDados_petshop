require 'sqlite3'
require 'minitest/autorun'

class Interface
  def initialize
    @tentativas = 3
    @user = ''
    @passwd = ''
  end

  def tela_inicial
    puts '@@@@@@@@@@@@ LOJA PETSHOP @@@@@@@@@@@@@@'
    puts '@@                                    @@'
    puts '@@   0 - Sair                         @@'
    puts '@@   1 - Fazer Agendamento            @@'
    puts '@@   2 - Mostrar clientes             @@'
    puts '@@   3 - Mostrar dias agendados       @@'
    puts '@@   4 - Alterar dados de uma tabela  @@'
    puts '@@                                    @@'
    puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  end

  def tela_despedida
    puts ''
    puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    puts '@@@@@   ATÉ LOGO!    @@@@@@@'
    puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
  end

  def limpe
    system('clear')
  end

  def organizando
    puts ''
    puts " id | nome_dono | nome_pet | raca "
    puts "-----------------------------------------"
  end

  def organizando2
    puts ''
    puts " id | data | hora "
    puts "-----------------------------------------"
  end

  def pagina_principal
    puts '@@@@@@@@@@@@@@@@@@@@@@@'
    puts '@   1. FAZER LOGIN    @'
    puts '@   2. CADASTRAR-SE   @'
    puts '@   3. SAIR           @'
    puts '@@@@@@@@@@@@@@@@@@@@@@@'
  end

  def pagina_cadastre_se
    limpe()
    puts 'OPERAÇÃO IMPOSSÍVEL...'
    puts 'Estamos em manunteção!'
    sleep(2)
  end

  def telalogin
    sleep(0.5)
    limpe()

    puts '-=-= TELA DE LOGIN -=-=-'
    puts "                          *tentativas de login: #{@tentativas}"
    puts 'USUARIO:'
    @user = gets.strip.to_s
    puts 'SENHA: '
    @passwd = gets.strip.to_s
  end

  def falha_no_login
    puts 'Voce digitou incorreta muitas vezes!'
  end

  def login(contas)
    log = false
    while log == false
      telalogin()
      for k in contas
        if @user == k['usuario'] and @passwd == k['senha']
          puts ''
          puts 'LOGIN FEITO COM SUCESSO'
          sleep(2)
          limpe()

          puts 'Aguarde'
          sleep(1)
          puts 'Carregando'
          sleep(1)
          puts 'Informações ...'
          sleep(3.3)
          limpe()
          log = true
          break
        elsif @user == k['usuario'] and @passwd != k['senha']
          @tentativas -= 1
          puts ''
          puts 'Dados inválidos!'
          sleep(2)
          limpe()
          if @tentativas == 0
            pagina_principal()
          end
        elsif @user != k['usuario'] and @passwd == k['senha']
          @tentativas -= 1
          puts ''
          puts 'Dados inválidos!'
          sleep(2)
          limpe()
        else
          @tentativas -= 1
          puts ''
          puts 'Dados inválidos!'
          sleep(2)
          limpe()
        end
      end
      if @tentativas == 0
        falha_no_login()
      end
    end
  end
end


class ManipulacaoBanco
  def clientes_ja_cadastrados(t_clientes)
    for k in t_clientes
      sleep(1)
      puts "-> #{k['_id']} | #{k['nome_dono']} | #{k['nome_pet']} | #{k['raca']}"
      puts ''
    end
    puts "-----------------------------------------"
  end

  def clientes_horarios(t_marcados)
    for k in t_marcados
      sleep(1)
      puts "-> #{k['_id']} | #{k['data']} | #{k['hora']}"
      puts ''
    end
    puts "-----------------------------------------"
  end
end


class TestBancoPetshop < Minitest::Test
  def test_banco__petshop
    db = SQLite3::Database.open 'petshop.db'
    db.results_as_hash = true

    ################## TABELA CADASTRO PET ###############################
    db.execute 'CREATE TABLE IF NOT EXISTS cadastroPet(
      _id INTEGER PRIMARY KEY,
      nome_dono TEXT NOT NULL,
      nome_pet TEXT,
      raca TEXT,
      data_nascimento TEXT,
      telefone TEXT
    )'

    db.execute 'DELETE FROM cadastroPet'
    db.execute 'INSERT INTO cadastroPet VALUES(?, ?, ?, ?, ?, ?)', nil, 'joao', 'pingo', 'pitbull', '07-10-2002', '8290202019'
    db.execute 'INSERT INTO cadastroPet VALUES(?, ?, ?, ?, ?, ?)', nil, 'karol', 'bob','pit', '04-01-2003', '400289221'
    db.execute 'INSERT INTO cadastroPet VALUES(?, ?, ?, ?, ?, ?)', nil, 'Welligton', 'zeus','vira-lata', '01-04-1995', '829393819'
    #########################################################################
    
    ################### TABELA DE HORARIO ######################################
    db.execute 'CREATE TABLE IF NOT EXISTS marcarHorario(
    _id INTEGER PRIMARY KEY,
    data TEXT NOT NULL,
    hora TEXT NOT NULL
    )'
    tabela3 = db.execute 'SELECT * FROM marcarHorario'
    horarios_marcados = tabela3
    ##############################################################################

    ############## TABELA DE CONTAS LOGIN ########################################
    db.execute 'CREATE TABLE IF NOT EXISTS contasUsuarios(
      _id INTEGER PRIMARY KEY,
      usuario TEXT NOT NULL,
      senha TEXT NOT NULL
    )'

    db.execute 'DELETE FROM contasUsuarios'
    db.execute 'INSERT INTO contasUsuarios VALUES(?, ?, ?)', nil, 'admin', 'admin'
    ################################################################################

    tabela2 = db.execute 'SELECT * FROM contasUsuarios'
    contas_existentes = tabela2.to_a

    tabela = db.execute 'SELECT * FROM cadastroPet'
    clientes_cadastrados = tabela.to_a

    tela = Interface.new()
    mostre = ManipulacaoBanco.new()

    tela.pagina_principal()
    puts 'Digite uma opção'
    res = gets.to_i

    if res == 1  #OPÇÕES DE LOGIN E CADASTRO
      tela.login(contas_existentes)
    elsif res == 2
      puts ''
      puts '##### Tela de Cadastro de conta #####'
      puts ''

      puts 'Digite um usuario de login: '
      usuario = gets.strip.to_s
      puts 'Informe uma senha: '
      senha = gets.strip.to_s
      puts 'Confirme a senha:'
      senha = gets.strip.to_s

      db.execute 'INSERT INTO contasUsuarios VALUES(?, ?, ?)', nil, usuario, senha
      tabela2 = db.execute 'SELECT * FROM contasUsuarios'
      contas_existentes = tabela2.to_a

      tela.login(contas_existentes)
    elsif res == 3
      tela.tela_despedida()
    end

    while true  # LOOP PRINCIPAL
      tela.tela_inicial()
      puts ''
      msg = puts 'Informe sua opção(0, 1, 2 ou 3): '
      opcao = gets

      if opcao.to_i == 1  # AGENDAR CLIENTE E ATUALIZAR O BANCO
        tela.limpe()
        puts '-=-=-=- OPÇÃO 1 ESCOLHIDA -=-=-=-'
        puts 'Antes de tudo, você ja é cliente?[S/N]'
        escolha = gets.strip.to_s

        if escolha == 'S' or escolha == 's'
          puts 'OK, ja que voce já é cadastrado'
          puts 'vamos apenas agendar seu horário.'
          sleep(3.5)

          tela.limpe()
          puts 'Preencha os dados corretamente abaixo.'
          puts ''
          puts 'formato de data: dia-mes-ano'
          puts 'Qual a data você gostaria?'
          data = gets.to_s
          puts ''
          puts 'formato do horario: 16:00'
          puts 'E o horario?'
          horario = gets.to_s
          puts ''
          puts 'Verificando se há vagas disponível nesse dia e horário... aguarde'
          sleep(4)

          tela.limpe()

          db.execute 'INSERT INTO marcarHorario VALUES(?, ?, ?)', nil, data, horario
          tabela3 = db.execute 'SELECT * FROM marcarHorario'
          horarios_marcados = tabela3

          puts 'AGENDAMENTO CONCLUÍDO!'
          sleep(3)

        elsif escolha == 'N' or escolha == 'n'
          puts ''
          puts 'VAMOS CADASTRA-LO NO SISTEMA'
          puts ''
          puts 'Preencha todos os dados que aparecerem corretamente'
          puts ''
          sleep(3)
          tela.limpe()
          puts ''
          puts 'Informe seu nome ou sobrenome: '
          seu_nome = gets.strip.to_s

          puts ''
          puts 'Agora o nome do seu pet: '
          nome_animal = gets.strip.to_s

          puts ''
          puts 'Raça do seu animal(Obrigatório): '
          raca_animal = gets.strip.to_s

          puts ''
          puts 'formato de data, ex:   07-10-2000 '
          puts 'Sua data de nascimento: '
          data_nascimento = gets.strip.to_s

          puts ''
          puts 'Numero celular(Opcional): '
          nmr_cel = gets.strip.to_s
          sleep(3)
          tela.limpe()

          puts ''
          puts 'Guardando informações . . .'
          sleep(3)
          puts 'TUDO OK!'

          db.execute 'INSERT INTO cadastroPet VALUES(?, ?, ?, ?, ?, ?)', nil, seu_nome, nome_animal, raca_animal, data_nascimento, nmr_cel      
          tabela = db.execute 'SELECT * FROM cadastroPet'
          clientes_cadastrados = tabela.to_a
        end


      elsif opcao.to_i == 2 # MOSTRA DADOS ANTIGOS OU ATUALIZADOS
        tela.limpe()
        puts '-=-=-=- Opção 2 escolhida -=-=-=-'
        puts 'Carregando sistema, aguarde ...'
        sleep(2.5)
        puts ''

        tela.organizando()
        mostre.clientes_ja_cadastrados(clientes_cadastrados)
        sleep(3)
        

      elsif opcao.to_i == 3 #MOSTRAR DADOS ANTIGOS OU ATUALIZADOS
        tela.limpe()
        puts '-=-=-= Opção 3 escolhida -=-=-=-'
        puts 'Carregando dados do sistema, aguarde . . .'
        sleep(2.5)
        puts ''

        tela.organizando2()
        mostre.clientes_horarios(horarios_marcados)
        sleep(3)

      elsif opcao.to_i == 0
        tela.limpe()
        break

      else
        puts 'OPÇÃO INVÁLIDA! Tente novamente...'
        sleep(2)
        tela.limpe()
      end
    end

    tela.tela_despedida()
  end
end
