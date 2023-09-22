// SPDX-License-Identifier: GPL-3.0
// Contrato na rede sepolia : 0x89082c584B417C0b01aA6cf5895045E55e5F2C5e
// Exercicio Final Semana 1 - Blockchain 
// Valerio Falcao
// valerio.falcao@bradesco.com.br
pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/jeffprestes/cursosolidity/bradesco_token_aberto.sol";
import "https://github.com/jeffprestes/cursosolidity/cadastro.sol";

//import "./lib/jeffprestes/bradesco_token_aberto.sol";
//import "./lib/jeffprestes/cadastro.sol";

contract ExercicioSolidity {
    /*

      Crie um contrato que, no momento do deploy (publicação) do contrato na rede 
      blockchain de Testes Sepolia, faça:

      a) registro dos dados do cliente que o contrato fará a custodia dos tokens;
      b) instancie o token chamado "ExercicioToken" que esta publicado no 
         endereço: 0x89A2E711b2246B586E51f579676BE2381441A0d0

         --> ExercicioToken @ local VM : 0xd9145CCE52D386f254917e481eB44e9943F39138
         --> Cadastro       @ local VM : 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
    */

    address internal constant EXERCICIO_TOKEN_ADDR_SEPOLIA  = 0x89A2E711b2246B586E51f579676BE2381441A0d0;
    address internal constant EXERCICIO_TOKEN_ADDR_LOCAL_VM = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    address internal constant CADASTRO_ADDR_SEPOLIA = 0x90bd50B003A79b8C99C402476D297A2cE50fa3ca;
    address internal constant CADASTRO_ADDR_LOCAL_VM = 0xcD6a42782d230D7c13A74ddec5dD140e55499Df9;

    address internal constant EXERCICIO_TOKEN_ADDR = EXERCICIO_TOKEN_ADDR_SEPOLIA;
    address internal constant CADASTRO_ADDR        = CADASTRO_ADDR_SEPOLIA;

    event EtherRecebido();

    Cadastro.Cliente private cliente;
    ExercicioToken private exToken;

    constructor(string memory _primeiroNome, 
                string memory _sobreNome, 
                string memory _agencia, 
                string memory _conta) payable {

        exToken = ExercicioToken(EXERCICIO_TOKEN_ADDR);

        Cadastro cadastro = Cadastro(CADASTRO_ADDR);

        cadastro.addCliente (_primeiroNome, _sobreNome, _agencia, _conta);
        bool ok;
        (cliente, ok) = cadastro.getClientePeloId(cadastro.totalClientes()-1);
        require(ok, "problemas na criacao do cliente");

    }
    /**

         E depois este mesmo contrato deve dispor duas funções (metodos) publicos:

         a) MeuSaldo, onde retorna o saldo em tokens "ExercicioToken" do 
            **contrato** que esta fazendo a custodia do mesmo para o cliente;

    */
    function MeuSaldo() public view returns (uint256) {
        return exToken.balanceOf(address(this));
    }
    /** 

         b) GerarTokenParaEuCliente, que gera novos tokens "ExercicioToken" 
            na quantidade informada como parametro para a função para 
            **o contrato que esta fazendo a custodia** dos tokens "ExercicioToken" 
            para o cliente;

    */
    function GerarTokenParaEuCliente(uint256 _amount) public returns (bool) {
        require(MeuSaldo() + _amount >= 100, "So vai ser possivel saldo de 100 ou mais");
        return exToken.mint(address(this),_amount);
    }

    /*   a) Adicionar função que transfere tokens em nome do cliente para um terceiro. */

    function TransfereTokensDoClienteParaTerceiro(address _to, uint256 _value) public returns (bool) {
        require( MeuSaldo() - _value >= 100, "O saldo nao pode ser menor que 100");
        exToken.transfer(_to, _value);

        return true;
    }

    /*   b) Criar uma função para retornar o saldo do contrato que esta fazendo a 
            custodia para o cliente em criptomoeda nativa da rede */

    function SaldoNativoDaRede() public view returns (uint256) {
        return address(this).balance;
    }


    /*   c) Adicionar função que transfere criptomoeda nativa da rede em nome do 
            cliente para um terceiro */

       /* a logica atual criou EXTC apenas para o contrato custodiante */
       /* provavelmente sera necessario tentar adicionar fundos aqui */

    function TransfereMoedaNativaDaRede(address payable _to, uint256 _value) public payable {
        //(bool ok, ) = _to.call{value: msg.value}("");
        (bool ok, ) = _to.call{value: _value}("");
        require(ok, "Failed to send Ether");
    }

    /* como anotacoes sobre o metodo acima :
       https://solidity-by-example.org/sending-ether/


    function sendViaTransfer(address payable _to) public payable {
        // This function is no longer recommended for sending Ether.
        _to.transfer(msg.value);
    }

    function sendViaSend(address payable _to) public payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

   */

    receive() external payable {
        emit EtherRecebido();
    }

}