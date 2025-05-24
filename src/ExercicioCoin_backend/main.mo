import ExercicioCoinLedger "canister:ExercicioCoin_icrc1_ledger_canister";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Error "mo:base/Error";

actor ExercicioCoin {
  
  type TokenInfo = {
    name : Text; //Nome completo do token (ex: "Internet Computer Protocol")
    symbol : Text; //Símbolo do token (ex: "ICP")
    totalSupply : Nat; //Quantidade total de tokens em circulação, representada como Nat (número natural não-negativo)
    fee : Nat; //Taxa de transferência do token
    mintingPrincipal : Text; //Identificador do Principal autorizado a emitir novos tokens
  };

  type TransferArgs = {
    amount : Nat; //Quantidade de tokens a serem transferidos
    toAccount : ExercicioCoinLedger.Account; //Conta de destino que recebera os tokens
  };


  //Funçoes para reobtener informações do token 
  //retornar o name do token ICRC-1.
  public func getTokenName() : async Text {
    //alias ExercicioCoin que acessa a funçao do canister token ICRC-1
    let name = await ExercicioCoinLedger.icrc1_name();
    return name;
  };

  //retornar o symbol do token ICRC-1
  public func getTokenSymbol() : async Text {
    let symbol = await ExercicioCoinLedger.icrc1_symbol();
    return symbol;
  };

  //retornar o total supply do token ICRC-1
  public func getTokenTotalSupply() : async Nat {
    let totalSupply = await ExercicioCoinLedger.icrc1_total_supply();
    return totalSupply;
  };

  //retornar a taxa de fee do token ICRC-1
  public func getTokenFee() : async Nat {
    let fee = await ExercicioCoinLedger.icrc1_fee();
    return fee;
  };

  //retornar o Principal ID da identidade minter do token ICRC-1
  public func getTokenMintingPrincipal() : async Text {
    let mintingAccountOpt = await ExercicioCoinLedger.icrc1_minting_account();

    switch (mintingAccountOpt) {
      case (null) { return "Nenhuma conta de mintagem localizada!" };
      case (?account) {
        // Converte o principal para texto
        return Principal.toText(account.owner);
      };
    };
  };

  // Retorna as informações do token.
  public func getTokenInfo() : async TokenInfo {

    let name = await getTokenName();
    let symbol = await getTokenSymbol();
    let totalSupply = await getTokenTotalSupply();
    let fee = await getTokenFee();
    let mintingPrincipal = await getTokenMintingPrincipal();

    let info : TokenInfo = {
      name = name;
      symbol = symbol;
      totalSupply = totalSupply;
      fee = fee;
      mintingPrincipal = mintingPrincipal;
    };

    return info;
  };

  //Função para consultar o saldo de tokens de um Principal.
  // Retorna o saldo de tokens do Principal recebido por parâmetro
  public func getBalance(owner : Principal) : async Nat {
    let balance = await ExercicioCoinLedger.icrc1_balance_of({
      owner = owner;
      subaccount = null;
    });
    return balance;
  };

  //retorna o Principal ID do canister de backend
  public query func getCanisterPrincipal() : async Text {
    return Principal.toText(Principal.fromActor(ExercicioCoin));
  };

  // retorna o saldo de tokens do Principal do canister de backend
  public func getCanisterBalance() : async Nat {
    let owner = Principal.fromActor(ExercicioCoin);
    let balance = await getBalance(owner);
    return balance;
  };



  public shared (msg) func transferFrom(to : Principal, amount : Nat) : async Result.Result<ExercicioCoinLedger.BlockIndex, Text> {
    let transferFromArgs : ExercicioCoinLedger.TransferFromArgs = {
      //especificar uma subconta do “gastador” (spender) ao realizar a transferência de tokens
      spender_subaccount = null;
      //a conta de origem de onde os tokens serão transferidos. owner = msg.caller: Identifica o Principal ID do proprietário da conta
      from = { owner = msg.caller; subaccount = null };
      // conta de destino. owner = to: Identifica o Principal ID do proprietário da conta de destino.
      to = { owner = to; subaccount = null };
      //quantidade de tokens a serem transferidos
      amount = amount;
      // taxa
      fee = null;
      memo = null;
      //indicar um timestamp de quando a transação foi criada
      created_at_time = null;
    };
    try {
      let transferResult = await ExercicioCoinLedger.icrc2_transfer_from(transferFromArgs);
      switch (transferResult) {
        case (#Err(transferError)) {
          return #err("Não foi possível transferir fundos:\n" # debug_show (transferError));
        };
        case (#Ok(blockIndex)) { return #ok blockIndex };
      };
    } catch (error : Error) {
      return #err("Mensagem de rejeição: " # Error.message(error));
    };
  };



};
