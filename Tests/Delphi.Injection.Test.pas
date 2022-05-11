﻿unit Delphi.Injection.Test;

interface

uses DUnitX.TestFramework, System.Rtti, Delphi.Injection, System.Classes;

type
{
  Testes a serem feitos:
  - Quando resolver uma classe, tem que encontrar todos os tipos esperados no contrutor da classe
  - Lançar um erro quando não encontrar todos os parâmetros do construtor da classe
  - Tem um opção de configuração para tentar achar um construtor qualquer, para construir a classe, independente do nível de herança
  - Se no nível atual não tiver um construtor tem que ir para a base da classe, e assim por diante até encontrar o construtor do TObject
    * Tem que verificar se a classe sendo contruída tem construtor, se tiver e não conseguir construir tem que dar erro
    * Isso tem que ocorrer em todos os níveis, salvo, não encontrar contrutor me nível nenhum
  - Se tentar resolver um interface, tem que buscar na lista de tipos, qual implementa essa classe e construir a mesma
  - Injetar campos das classes, isso tem que ser via anotação
  - Permitir registrar construtores para os tipos, afim de permitir o programador decidir como a instância deve ser gerada
  - Controle de ciclo de vida do objecto (Singleton, Thread, etc...)
    * Ideia, quando o ciclo de vida por por thread, quando for requisitado para resolver algum valor dentro de um thread, abrir um outra thread que chama o WaitFor da thread corrente, e quando terminar, elimina
    as váriaveis criadas nessa thread
  - Limitar os tipos resolviveis á classes, interfaces e records?
    * Acredito que sim, por que os tipos nativos, não tem por que serem resolvidos, e no caso do records, apenas os campos podem ser resolvidos
  - Quando o construtor tiver objetos de parâmetros, tem que verificar se o parâmetro passado é igual ou derivado do parâmetro para aceitar o mesmo
  - Criar função de registro de tipo com uma fábrica de objetos
  - Registrar serviços nomeados para serem utilizados por nome depois
  - Como definir qual objeto derivado utilizar no construtor?
    * Provavelmente terei que utilizar anotações por não saber qual escolher
    * Mesmo assim pode existir mais de uma opção, mas resolver o problema do parâmetro se uma classe base

  Construindo uma interface
  - Localizar uma classe que implementa ela
    * Tem que verificar se as classes encontradas tem alguma anotação de nome de serviço. Se tiver, verificar se o parâmetro e nome de serviço fecha. Se encontrar mais de uma
      fechando os critérios, por nome de serviço ou padrão, tem que dar erro
  - Por uma anotação de qual classe deve ser criada
    * Teria que ser o nome, senão teria problema de referência circular
  - Por um fábrica de objetos, que implementem essa interface
    * Uma função fornecida pelo programdor para criar esse tipo de classe
  - A busca completa é muito lenta, verificar uma forma de armazenar um registro disso

  Contruindo uma class
  - Tem localizar os contrutores da própria classe
  - Senão encontrar contrutores na própria classe, tem que ir descendo os níveis, no primeiro que encontrar, tem que utilizar algum contrutor desse nível
    * Se os parâmetros não forem iguais, tem que dar erro
    * Se a classe tem derivações, e em algum nível de derivação exitir um construtor, tem que utilizar ele, para não dar o problema do Spring, de utilizar o contrutor do TObject,
      sendo que existe um contrutor em qualquer nível das classes herdadas

  Injeção
  - Fazer injeção de campos nas classes

  Fábrica
  - Basicamente, tudo aqui é para encontrar a fábrica de um tipo específico e retornar a instância dele
  - Na fábrica de objetos, tem que permitir utilizar apenas construtores públicos
  - Quando tentar resolver um tipo, tem que registrar uma fábrica para esse tipo
    * O registro do nome, por ser o nome qualificado da classe + nome do serviço, se existir (MinhaClass.TMeuTipo-MeuServico)
    * Talvez colocar no nome de registro, os parâmetros de construção
      ** O problema disso, seriam as classes, interfaces e records, ou seja, qualquer tipo não nativo. Com isso poderia gerar a mesma assinatura, para construtores diferentes
}

  [TestFixture]
  TInjectorTest = class
  private
    FInjector: TInjector;
  public
    [SetupFixture]
    procedure SetupFixture;
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenResolveAnClassMustCreateTheClassAndReturnTheInstance;
    [Test]
    procedure WhenTheClassHasItsOwnContrutctorThisMustBeCalledInTheResolver;
    [Test]
    procedure WhenTheContructorHasParamsAndTheParamIsPassedInTheResolverMustCreateTheClassWithThisParams;
    [TestCase('No param', '123,abc')]
    [TestCase('One param', '456,abc,456')]
    [TestCase('Two params', '789,def,789,def')]
    procedure WhenTheClassHasMoreThenOneContructorMustSelectTheConstructorByTheTypeOfThePassedParams(ExpectParam1: Integer; ExpectParam2: String; ParamValue1: Integer; ParamValue2: String);
    [Test]
    procedure WhenAClassDoesntHaveAConstructorMustCreateTheClassFromTheBaseClassConstructor;
    [Test]
    procedure WhenTheConstructorsOfTheClassHasTheSameParamCountMustCreateTheClassByTheSignatureOfTypeOfTheParamsOfTheConstructor;
    [Test]
    procedure WhenTheConstructorsOfTheClassHasTheSameParamCountMustCreateTheClassByTheSignatureOfTypeOfTheParamsOfTheConstructor2;
    [Test]
    procedure IfCantFindTheConstructorMustToRaiseAnError;
    [Test]
    procedure WhenTryToResolveAnInterfaceMustLocateTheClassThatImplementsAndCreateTheClass;
    [Test]
    procedure WhenRegisterAFactoryMustUseTheFactoryToCreateTheResolvedObject;
  end;

  [TestFixture]
  TFunctionFactoryTest = class
  public
    [Test]
    procedure WhenUseTheFunctionFactoryMustCallThePassedFunctionToFactory;
    [Test]
    procedure WhenCallTheFactoryConstructorMustPassTheParamsToTheFunction;
    [Test]
    procedure TheConstructorFunctionMustReturnTheInstanceOfTheObjectCreated;
    [Test]
    procedure TheInstanceCreatedMustBeTheTypeExpected;
  end;

  [TestFixture]
  TObjectFactoryTest = class
  private
    FContext: TRttiContext;
  public
    [Setup]
    procedure Setup;
    [Test]
    procedure WhenCallTheConstructMustCreateTheClassInsideTheFactory;
    [Test]
    procedure WhenTheClassHasAConstrutorMustCallThisConstructorOnTheFactory;
    [Test]
    procedure WhenTheClassConstructorHasParamsThisParamsMustBePassedInTheInvokerOfTheConstuctor;
    [TestCase('No param', '123,abc')]
    [TestCase('One param', '456,abc,456')]
    [TestCase('Two params', '789,def,789,def')]
    procedure WhenTheClassHasMoreThenOneContructorMustSelectTheConstructorByTheCountOfTheParams(ExpectParam1: Integer; ExpectParam2: String; ParamValue1: Integer; ParamValue2: String);
    [Test]
    procedure WhenCantFindAConstructorMustRaiseAnError;
    [TestCase('String param', '0,abc')]
    [TestCase('Integer param', '123,')]
    procedure WhenTheClassHasMoreThenOneContructorWithSameQuantityOfParamsMustSelectTheConstructorByTheParamType(const IntegerParam: Integer; const StringParam: String);
  end;

  TSimpleClass = class
  end;

  TClassWithConstructor = class
  private
    FTheConstructorCalled: Boolean;
  public
    constructor Create;

    property TheConstructorCalled: Boolean read FTheConstructorCalled write FTheConstructorCalled;
  end;

  TClassWithParamsInConstructor = class
  private
    FParam1: TObject;
    FParam2: Integer;
  public
    constructor Create(Param1: TObject; Param2: Integer);

    property Param1: TObject read FParam1 write FParam1;
    property Param2: Integer read FParam2 write FParam2;
  end;

  TClassWithThreeContructors = class
  private
    FParam1: Integer;
    FParam2: String;
  public
    constructor Create; overload;
    constructor Create(Param: Integer); overload;
    constructor Create(Param1: Integer; Param2: String); overload;

    property Param1: Integer read FParam1 write FParam1;
    property Param2: String read FParam2 write FParam2;
  end;

  TClassInheritedWithoutConstructor = class(TClassWithConstructor)
  private
    FEmptyProperty: Integer;
  public
    property EmptyProperty: Integer read FEmptyProperty write FEmptyProperty;
  end;

  TClassWithConstructorWithTheSameParameterCount = class
  private
    FIntegerProperty: Integer;
    FStringProperty: String;
  public
    constructor Create(Param: Integer); overload;
    constructor Create(Param: String); overload;

    property IntegerProperty: Integer read FIntegerProperty write FIntegerProperty;
    property StringProperty: String read FStringProperty write FStringProperty;
  end;

  IMyInterface = interface
    ['{904F4775-6482-447C-8FDA-849036C92077}']
  end;

  TMyObjectInterface = class(TInterfacedObject, IMyInterface)
  end;

implementation

uses System.TypInfo, System.SysUtils, Delphi.Mock;

{ TInjectorTest }

procedure TInjectorTest.IfCantFindTheConstructorMustToRaiseAnError;
begin
  Assert.WillRaise(
    procedure
    begin
      FInjector.Resolve<TClassWithConstructorWithTheSameParameterCount>([123.123]);
    end, EConstructorNotFound);
end;

procedure TInjectorTest.Setup;
begin
  FInjector := TInjector.Create;

  TMock.CreateInterface<IFactory>;
end;

procedure TInjectorTest.SetupFixture;
begin
  var Context := TRttiContext.Create;

  for var RttiType in Context.GetTypes do
  begin
    RttiType.GetMethods;

    RttiType.QualifiedName;
  end;

  Context.Free;
end;

procedure TInjectorTest.TearDown;
begin
  FInjector.Free;
end;

procedure TInjectorTest.WhenAClassDoesntHaveAConstructorMustCreateTheClassFromTheBaseClassConstructor;
begin
  var AClass := FInjector.Resolve<TClassInheritedWithoutConstructor>;

  Assert.IsNotNull(AClass);

  Assert.AreEqual(0, AClass.EmptyProperty);

  AClass.Free;
end;

procedure TInjectorTest.WhenRegisterAFactoryMustUseTheFactoryToCreateTheResolvedObject;
begin
  var Factory := TMock.CreateInterface<IFactory>;

  Factory.Expect.Once.When.Construct(It.IsAny<TArray<TValue>>);

  FInjector.RegisterFactory<IMyInterface>(Factory.Instance);

  FInjector.Resolve<IMyInterface>;

  Assert.CheckExpectation(Factory.CheckExpectations);
end;

procedure TInjectorTest.WhenResolveAnClassMustCreateTheClassAndReturnTheInstance;
begin
  var AClass := FInjector.Resolve<TSimpleClass>;

  Assert.IsNotNull(AClass);

  AClass.Free;
end;

procedure TInjectorTest.WhenTheClassHasItsOwnContrutctorThisMustBeCalledInTheResolver;
begin
  var AClass := FInjector.Resolve<TClassWithConstructor>;

  Assert.IsNotNull(AClass);

  Assert.IsTrue(AClass.TheConstructorCalled);

  AClass.Free;
end;

procedure TInjectorTest.WhenTheClassHasMoreThenOneContructorMustSelectTheConstructorByTheTypeOfThePassedParams(ExpectParam1: Integer; ExpectParam2: String; ParamValue1: Integer; ParamValue2: String);
begin
  var Params: TArray<TValue> := nil;

  if ParamValue1 > 0 then
  begin
    SetLength(Params, 1);
    Params[0] := ParamValue1;
  end;

  if not ParamValue2.IsEmpty then
  begin
    SetLength(Params, 2);
    Params[1] := ParamValue2;
  end;

  var AClass := FInjector.Resolve<TClassWithThreeContructors>(Params);

  Assert.IsNotNull(AClass);

  Assert.AreEqual(ExpectParam1, AClass.Param1);

  Assert.AreEqual(ExpectParam2, AClass.Param2);

  AClass.Free;
end;

procedure TInjectorTest.WhenTheConstructorsOfTheClassHasTheSameParamCountMustCreateTheClassByTheSignatureOfTypeOfTheParamsOfTheConstructor;
begin
  var AClass := FInjector.Resolve<TClassWithConstructorWithTheSameParameterCount>(['abc']);

  Assert.AreEqual('abc', AClass.StringProperty);

  AClass.Free;
end;

procedure TInjectorTest.WhenTheConstructorsOfTheClassHasTheSameParamCountMustCreateTheClassByTheSignatureOfTypeOfTheParamsOfTheConstructor2;
begin
  var AClass := FInjector.Resolve<TClassWithConstructorWithTheSameParameterCount>([123]);

  Assert.AreEqual(123, AClass.IntegerProperty);

  AClass.Free;
end;

procedure TInjectorTest.WhenTheContructorHasParamsAndTheParamIsPassedInTheResolverMustCreateTheClassWithThisParams;
begin
  var ObjectParam := TObject.Create;

  var AClass := FInjector.Resolve<TClassWithParamsInConstructor>([ObjectParam, 1234]);

  Assert.IsNotNull(AClass);

  Assert.AreEqual(ObjectParam, AClass.Param1);

  Assert.AreEqual(1234, AClass.Param2);

  AClass.Free;

  ObjectParam.Free;
end;

procedure TInjectorTest.WhenTryToResolveAnInterfaceMustLocateTheClassThatImplementsAndCreateTheClass;
begin
  var MyInterface := FInjector.Resolve<IMyInterface>;

  Assert.IsNotNull(MyInterface);
end;

{ TClassWithConstructor }

constructor TClassWithConstructor.Create;
begin
  inherited;

  FTheConstructorCalled := True;
end;

{ TClassWithParamsInConstructor }

constructor TClassWithParamsInConstructor.Create(Param1: TObject; Param2: Integer);
begin
  inherited Create;

  FParam1 := Param1;
  FParam2 := Param2;
end;

{ TClassWithThreeContructors }

constructor TClassWithThreeContructors.Create;
begin
  Create(123);
end;

constructor TClassWithThreeContructors.Create(Param: Integer);
begin
  Create(Param, 'abc');
end;

constructor TClassWithThreeContructors.Create(Param1: Integer; Param2: String);
begin
  inherited Create;

  FParam1 := Param1;
  FParam2 := Param2;
end;

{ TClassWithConstructorWithTheSameParameterCount }

constructor TClassWithConstructorWithTheSameParameterCount.Create(Param: String);
begin
  inherited Create;

  FStringProperty := Param;
end;

constructor TClassWithConstructorWithTheSameParameterCount.Create(Param: Integer);
begin
  inherited Create;

  FIntegerProperty := Param;
end;

{ TFunctionFactoryTest }

procedure TFunctionFactoryTest.TheConstructorFunctionMustReturnTheInstanceOfTheObjectCreated;
begin
  var Factory := TFunctionFactory<TSimpleClass>.Create(
    function (const Params: TArray<TValue>): TSimpleClass
    begin
      Result := TSimpleClass.Create;
    end) as IFactory;

  var Instance := Factory.Construct(nil);

  Assert.IsNotNull(Instance.AsObject);

  Instance.AsObject.Free;
end;

procedure TFunctionFactoryTest.TheInstanceCreatedMustBeTheTypeExpected;
begin
  var Factory := TFunctionFactory<TSimpleClass>.Create(
    function (const Params: TArray<TValue>): TSimpleClass
    begin
      Result := TSimpleClass.Create;
    end) as IFactory;

  var Instance := Factory.Construct(nil);

  Assert.AreEqual<TClass>(TSimpleClass, Instance.AsObject.ClassType);

  Instance.AsObject.Free;
end;

procedure TFunctionFactoryTest.WhenCallTheFactoryConstructorMustPassTheParamsToTheFunction;
begin
  var Factory := TFunctionFactory<TSimpleClass>.Create(
    function (const Params: TArray<TValue>): TSimpleClass
    begin
      Assert.AreEqual<NativeInt>(1, Length(Params));

      Assert.AreEqual(25, Params[0].AsInteger);

      Result := TSimpleClass.Create;
    end) as IFactory;

  var Instance := Factory.Construct([25]);

  Instance.AsObject.Free;
end;

procedure TFunctionFactoryTest.WhenUseTheFunctionFactoryMustCallThePassedFunctionToFactory;
begin
  var CalledFunction := False;
  var Factory := TFunctionFactory<TSimpleClass>.Create(
    function (const Params: TArray<TValue>): TSimpleClass
    begin
      CalledFunction := True;
      Result := TSimpleClass.Create;
    end) as IFactory;

  var Instance := Factory.Construct(nil);

  Instance.AsObject.Free;

  Assert.IsTrue(CalledFunction);
end;

{ TObjectFactoryTest }

procedure TObjectFactoryTest.Setup;
begin
  FContext := TRttiContext.Create;
end;

procedure TObjectFactoryTest.WhenCallTheConstructMustCreateTheClassInsideTheFactory;
begin
  var Factory := TObjectFactory.Create(FContext.GetType(TSimpleClass).AsInstance) as IFactory;
  var TheObject := Factory.Construct(nil).AsObject;

  Assert.IsNotNull(TheObject);

  TheObject.Free;
end;

procedure TObjectFactoryTest.WhenCantFindAConstructorMustRaiseAnError;
begin
  var Factory := TObjectFactory.Create(FContext.GetType(TSimpleClass).AsInstance) as IFactory;

  Assert.WillRaise(
    procedure
    begin
      Factory.Construct([123]);
    end);
end;

procedure TObjectFactoryTest.WhenTheClassConstructorHasParamsThisParamsMustBePassedInTheInvokerOfTheConstuctor;
begin
  var AnObject := TObject.Create;
  var Factory := TObjectFactory.Create(FContext.GetType(TClassWithParamsInConstructor).AsInstance) as IFactory;
  var TheObject := Factory.Construct([AnObject, 1234]).AsType<TClassWithParamsInConstructor>;

  Assert.IsNotNull(TheObject);

  Assert.AreEqual(AnObject, TheObject.Param1);

  Assert.AreEqual(1234, TheObject.Param2);

  AnObject.Free;

  TheObject.Free;
end;

procedure TObjectFactoryTest.WhenTheClassHasAConstrutorMustCallThisConstructorOnTheFactory;
begin
  var Factory := TObjectFactory.Create(FContext.GetType(TClassWithConstructor).AsInstance) as IFactory;
  var TheObject := Factory.Construct(nil).AsType<TClassWithConstructor>;

  Assert.IsTrue(TheObject.TheConstructorCalled);

  TheObject.Free;
end;

procedure TObjectFactoryTest.WhenTheClassHasMoreThenOneContructorMustSelectTheConstructorByTheCountOfTheParams(ExpectParam1: Integer; ExpectParam2: String; ParamValue1: Integer; ParamValue2: String);
begin
  var Factory := TObjectFactory.Create(FContext.GetType(TClassWithThreeContructors).AsInstance) as IFactory;
  var Params: TArray<TValue> := nil;

  if ParamValue1 > 0 then
  begin
    SetLength(Params, 1);
    Params[0] := ParamValue1;
  end;

  if not ParamValue2.IsEmpty then
  begin
    SetLength(Params, 2);
    Params[1] := ParamValue2;
  end;

  var AClass := Factory.Construct(Params).AsType<TClassWithThreeContructors>;

  Assert.IsNotNull(AClass);

  Assert.AreEqual(ExpectParam1, AClass.Param1);

  Assert.AreEqual(ExpectParam2, AClass.Param2);

  AClass.Free;
end;

procedure TObjectFactoryTest.WhenTheClassHasMoreThenOneContructorWithSameQuantityOfParamsMustSelectTheConstructorByTheParamType(const IntegerParam: Integer; const StringParam: String);
begin
  var Factory := TObjectFactory.Create(FContext.GetType(TClassWithConstructorWithTheSameParameterCount).AsInstance) as IFactory;
  var Param: TValue;

  if IntegerParam > 0 then
    Param := IntegerParam
  else
    Param := StringParam;

  var AClass := Factory.Construct([Param]).AsType<TClassWithConstructorWithTheSameParameterCount>;

  Assert.IsNotNull(AClass);

  Assert.AreEqual(IntegerParam, AClass.IntegerProperty);

  Assert.AreEqual(StringParam, AClass.StringProperty);

  AClass.Free;
end;

end.

