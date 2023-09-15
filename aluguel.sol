/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.

--> 0x57cC630212c3Eff18Ee86427e586528D4F4a1E13 (versao inicial, com "owner")
--> 0x5fc37e161a4BCCE4045fE402d4561d1E107F156D

*/
pragma solidity 0.8.19;

contract Aluguel {
    string public locatario;
    string public locador;
    uint256 private valor;
    uint256 constant public numeroMaximoLegalDeAlugueisParaMulta = 3;
    bool[] public statusPagamento;
    /*
    0 - 01/2020 = true
    1 - 02/2020 = true
    2 - 03/2020 = true
    3 - 04/2020 = true
    */
    address payable public contaLocador;
    address public locatarioAddr;

    constructor(    string memory _nomeLocador, 
                    string memory _nomeLocatario, 
                    address payable _contaLocador, 
                    uint256 _valorDoAluguel)  payable {
        locador = _nomeLocador;
        locatario = _nomeLocatario;
        valor = _valorDoAluguel;
        contaLocador = _contaLocador;
        locatarioAddr = msg.sender;
    }
 
    function valorAtualDoAluguel() public view returns (uint256) {
        return valor;
    }
 
    function simulaMulta( uint256 mesesRestantes, uint256 totalMesesContrato) public view returns(uint256 valorMulta) 
    {
        valorMulta = valor*numeroMaximoLegalDeAlugueisParaMulta;
        valorMulta = valorMulta/totalMesesContrato;
        valorMulta = valorMulta*mesesRestantes;
        return valorMulta;
    } 
        
    function reajustaAluguel(uint256 percentualReajuste) public 
    {
        if (percentualReajuste > 20) {
            percentualReajuste = 20;
        }
        uint256 valorDoAcrescimo = 0;
        valorDoAcrescimo = ((valor*percentualReajuste)/100);
        valor = valor + valorDoAcrescimo;
    }
    
    function aditamentoValorAluguel(uint256 valorCerto) public   {
        valor = valorCerto;
    }

    function aplicaMulta(uint256 mesesRestantes, uint256 percentual) public     {
        require(mesesRestantes<30, "Periodo de contrato invalido");
        for (uint numeroDeVoltas=0; numeroDeVoltas < mesesRestantes; numeroDeVoltas=numeroDeVoltas+2) {
            valor = valor+((valor*percentual)/100);
        }
    }
    
    
    function receberPagamento() public payable {
        require(msg.value>=valor, "Valor insuficiente");
        require(msg.sender == locatarioAddr, "Apenas o locatario pode pagar o aluguel");
        contaLocador.transfer(msg.value);
        statusPagamento.push(true);
    }
    
    //msg.value = valor em wei enviado ao contrato
    
    function retornaTexto(uint256 _parametro) public view returns (string memory) {
        if ((valor * _parametro) > 5000) {
            return "Muito caro";
        } else {
            return "Preco razoavel";
        }
    }
    
    function quantosPagamentosJaForamFeitos() public view returns (uint256) {
        return statusPagamento.length;
    }
}
