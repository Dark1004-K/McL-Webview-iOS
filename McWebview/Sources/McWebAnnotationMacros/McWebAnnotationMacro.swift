import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
//public struct StringifyMacro: ExpressionMacro {
//    public static func expansion(
//        of node: some FreestandingMacroExpansionSyntax,
//        in context: some MacroExpansionContext
//    ) -> ExprSyntax {
//        guard let argument = node.arguments.first?.expression else {
//            fatalError("compiler bug: the macro does not have any arguments")
//        }
//
//        return "(\(argument), \(literal: argument.description))"
//    }
//}
public struct McWebFunctionMacro: PeerMacro {
    public static func expansion<Context: MacroExpansionContext, Declaration: DeclSyntaxProtocol>(
        of node: AttributeSyntax, // 매크로 호출 구문 (#McWebMethod 또는 @McWebMethod)
        providingPeersOf declaration: Declaration, // 매크로가 부착된 선언 (여기서는 함수)
        in context: Context // 매크로 확장에 대한 컨텍스트 정보
    ) throws -> [DeclSyntax] {
        // 1. 함수 선언인지 확인
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            // 함수가 아닌 곳에 붙었으면 에러 (또는 다른 처리)
            // 여기서는 단순화를 위해 빈 배열 반환 또는 에러 throw
            // context.diagnose(...) 등을 사용해 에러 메시지 표시 가능
            return []
        }

        // 2. 함수 이름 가져오기
        let actualFunctionName = funcDecl.name.text

        // 3. 매크로에서 'name' 인자 가져오기 (예: @McWebMethod(name: "customName"))
        var webFunctionName = actualFunctionName
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self) {
            for arg in arguments {
                if arg.label?.text == "name",
                   let stringLiteral = arg.expression.as(StringLiteralExprSyntax.self),
                   let nameSegment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                    webFunctionName = nameSegment.content.text
                    break
                }
            }
        }

        // 4. 파라미터 정보 분석 (단순화된 버전)
        // Kotlin 코드처럼 복잡한 런타임 타입 매핑 대신,
        // 여기서는 파라미터 이름을 추출하고, 핸들러에서 사용할 수 있도록 준비합니다.
        // 실제로는 파라미터 타입도 분석해서 더 정교한 코드 생성이 가능합니다.
        let parameters = funcDecl.signature.parameterClause.parameters
        var parameterNames: [String] = []
        var parameterSignatureForHandler: [String] = [] // 핸들러 클로저의 파라미터 시그니처 생성용
        var callArguments: [String] = [] // 실제 함수 호출 시 인자 목록 생성용

        for param in parameters {
            let paramName = param.firstName.text
            // 콜백 ID와 파라미터 딕셔너리를 제외한 실제 함수 파라미터만 고려
            if paramName != "callbackId" && paramName != "params" { // 이 부분은 실제 사용 방식에 따라 조정
                parameterNames.append(paramName)

                // 핸들러 클로저에서 사용할 때 타입 캐스팅 예시 (단순화)
                // 실제로는 param.type을 분석해서 정확한 타입 캐스팅 코드를 생성해야 합니다.
                // 여기서는 String으로 가정하고, 옵셔널 처리도 단순화합니다.
                let paramType = param.type.trimmedDescription // 예: "String", "Int?", "MyCustomType"
                // 여기서는 모든 파라미터를 params 딕셔너리에서 String?으로 가져온다고 가정합니다.
                // 실제 프로덕션 코드에서는 훨씬 더 정교한 타입 분석 및 캐스팅 코드 생성이 필요합니다.
                parameterSignatureForHandler.append("\(paramName): \(paramType)") // 이건 실제 함수 시그니처 반영
                callArguments.append("\(paramName): \(paramName)") // 핸들러 내에서 변수 사용
            }
        }


        // 5. 등록할 함수에 대한 핸들러 코드 (클로저) 생성
        // 이 클로저는 (String?, [String: Any]?) -> Void 시그니처를 가집니다.
        // Kotlin의 functionLambda 와 유사한 역할을 합니다.
        // `pluginInstance`는 이 코드가 실제로 위치할 클래스/구조체의 인스턴스를 참조해야 합니다.
        // 여기서는 `self`로 가정합니다. (매크로가 부착된 타입의 인스턴스)
        // 실제로는 pluginInstance를 어떻게 전달받을지 설계가 필요합니다.
        // 여기서는 매크로가 static 함수를 생성하고, 그 함수 내부에서 self (플러그인 인스턴스)를 사용한다고 가정.

        let handlerArguments = "callbackId: String?, params: [String: Any]?"
        var handlerBody = """
        // Parameters: \(parameterNames.joined(separator: ", "))
        // Original function: \(actualFunctionName)
        // Web function name: \(webFunctionName)

        """
        // 파라미터 추출 및 타입 변환 로직 (매우 단순화된 예시)
        // Kotlin의 mappingParam 함수의 일부 역할을 여기서 수행
        for param in parameters {
            let paramName = param.firstName.text
//            guard let paramTypeSyntax = param.type else { continue }
            let paramTypeSyntax = param.type
            let paramTypeName = paramTypeSyntax.trimmedDescription
            let isOptional = paramTypeName.hasSuffix("?")
            let baseTypeName = isOptional ? String(paramTypeName.dropLast()) : paramTypeName

            // callbackId 는 직접 주입
            if paramName == "callbackId" {
                // handlerBody += "let \(paramName) = callbackId\n" // callbackId는 이미 핸들러 파라미터로 존재
                continue // callbackId는 이미 핸들러의 파라미터임
            }


            // 일반 파라미터는 params 딕셔너리에서 추출
            if isOptional {
                handlerBody += "let \(paramName) = params?[\"\(paramName)\"] as? \(baseTypeName)\n"
            } else {
                handlerBody += "guard let \(paramName)Value = params?[\"\(paramName)\"] else {\n"
                handlerBody += "    print(\"Error: Missing required parameter '\(paramName)' for \(actualFunctionName).\")\n"
                handlerBody += "    self.sendResult(status: .failure, callbackId: callbackId, param: McWebFailure(message: \"Missing required parameter: \(paramName)\"))\n" // sendResult 호출 가정
                handlerBody += "    return\n"
                handlerBody += "}\n"
                
                // 타입 캐스팅 (매우 기본적인 예시)
                // 실제로는 더 많은 타입을 지원해야 함 (Int, Bool, Double, 커스텀 객체 등)
                // 커스텀 객체의 경우 Decodable을 활용한 파싱 로직 생성 가능
//                if baseTypeName == "String" || baseTypeName == "Int" || baseTypeName == "Bool" || baseTypeName == "Double" {
                handlerBody += "guard let \(paramName) = \(paramName)Value as? \(baseTypeName) else {\n"
                handlerBody += "    print(\"Error: Invalid type for parameter '\(paramName)'. Expected \(baseTypeName), got \\(type(of: \(paramName)Value))\")\n"
                handlerBody += "    self.sendResult(status: .failure, callbackId: callbackId, param: McWebFailure(message: \"Invalid type for parameter: \(paramName)\"))\n"
                handlerBody += "    return\n"
                handlerBody += "}\n"
                // ... 다른 타입들에 대한 처리 추가 ...

            }
//
//            if isOptional && baseTypeName != "String" && baseTypeName != "Int" && baseTypeName != "Bool" { // 옵셔널이고, 아직 할당 안된 경우 (캐스팅 실패 시)
//                 handlerBody += "let \(paramName): \(paramTypeName) = \(paramName)Value as? \(baseTypeName) // Assign if cast succeeds, else nil for optional\n"
//            }
        }


        // 실제 함수 호출 부분 생성
        let functionCallArguments = parameters.map { param in
            let paramName = param.firstName.text
            if paramName == "callbackId" {
                return "callbackId: callbackId"
            }
            // `params`라는 이름의 파라미터가 함수 시그니처에 있다면, params 딕셔너리 전체를 전달
            // 그렇지 않으면 위에서 추출한 개별 파라미터를 사용
            if funcDecl.signature.parameterClause.parameters.contains(where: { $0.firstName.text == "params" && $0.type.trimmedDescription == "[String: Any]?"}) && paramName == "params" {
                 return "params: params"
            }
            return "\(paramName): \(paramName)"
        }.joined(separator: ", ")

        handlerBody += "\n"
        handlerBody += "self.\(actualFunctionName)(\(functionCallArguments))\n"
        // 성공 결과는 보통 호출된 함수 내부에서 sendResult를 통해 보낼 것이므로 여기서는 생략
        // 또는 기본 성공 메시지를 여기서 보낼 수도 있음
        // handlerBody += "self.sendResult(status: \"success\", callbackId: callbackId, data: [\"message\": \"\(actualFunctionName) executed\"])\n"


        // 6. 생성될 코드 (새로운 정적 프로퍼티 또는 함수)
        // 여기서는 각 함수에 대한 McWebFunction 정의를 생성하고,
        // 이를 어딘가에 등록하는 코드를 만듭니다.
        // 예시: 정적 배열에 추가하는 코드를 생성
        // 또는 특정 레지스트리 객체의 메서드를 호출하는 코드를 생성

        // 이 코드는 매크로가 부착된 타입의 extension에 추가될 수 있습니다.
        // 또는 별도의 파일에 생성될 수도 있습니다. (Attached Macro의 경우 PeerMacro 사용)
        // 여기서는 설명을 위해 간단한 문자열로 생성합니다.
        // 실제로는 SwiftSyntaxBuilder를 사용해 더 안전하게 Syntax 노드를 생성합니다.

        let generatedCode = """
        // Generated by McWebMethodMacro for \(actualFunctionName)
        var generated_\(webFunctionName)_mcWebFunction: McWebFunction {
            McWebFunction(name: "\(webFunctionName)") { [weak self] (callbackId: String, params: [String: Any]?) in
                guard let self = self else {
                    print("Error: Plugin instance is nil for \(webFunctionName)")
                        // 여기서 sendResult를 직접 호출할 수 없으므로, 로깅만 하거나 다른 방식을 고려해야 합니다.
                        // 예를 들어, 핸들러가 Result 타입을 반환하게 하고, 외부에서 sendResult를 호출할 수 있습니다.
                    return
                }
                \(handlerBody)
            }
        }
        """
        // context.addDiagnostics(from: YourError(), node: node) 등으로 에러 리포팅 가능
        return [DeclSyntax(stringLiteral: generatedCode)]
    }
    
    func makeParam() {
        
    }
}





public struct McWebPluginMacro: MemberMacro {
    
    public static func expansion(
          of node: AttributeSyntax,
          providingMembersOf declaration: some DeclGroupSyntax,
          conformingTo protocols: [TypeSyntax],
          in context: some MacroExpansionContext
      ) throws -> [DeclSyntax] {
          
          guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
              return []
          }

          // 1. 매크로의 `name` 인자 값을 가져옵니다.
          var pluginName: String? = nil
          if let arguments = node.arguments?.as(LabeledExprListSyntax.self) {
              if let nameArg = arguments.first(where: { $0.label?.text == "name" }) {
                  if let stringLiteral = nameArg.expression.as(StringLiteralExprSyntax.self),
                     let nameSegment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                      pluginName = nameSegment.content.text
                  }
              }
          }
          
          // name 인자가 없다면 클래스 이름을 기본값으로 사용
          let finalPluginName = pluginName ?? classDecl.name.text
          
          // 2. `@McWebMethod`가 붙은 모든 함수를 찾습니다.
          let webMethods = classDecl.memberBlock.members.compactMap { member in
              member.decl.as(FunctionDeclSyntax.self).flatMap { funcDecl in
                  funcDecl.attributes.contains(where: { attr in
                      attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "McWebMethod"
                  }) ? funcDecl : nil
              }
          }

          // 3. 플러그인 등록 코드를 생성합니다.
          var registrationStatements: [String] = []
          for funcDecl in webMethods {
              let actualFunctionName = funcDecl.name.text
              
              // 수정된 부분: AttributeListSyntax.Element를 AttributeSyntax로 명시적으로 캐스팅합니다.
              let webFunctionName = funcDecl.attributes.first(where: {
                  $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "McWebMethod"
              })?
              .as(AttributeSyntax.self)?  // <- 이 부분 추가
              .arguments?
              .as(LabeledExprListSyntax.self)?
              .first(where: { $0.label?.text == "name" })?
              .expression
              .as(StringLiteralExprSyntax.self)?
              .segments.first?
              .as(StringSegmentSyntax.self)?
              .content.text ?? actualFunctionName

              let registrationCode = """
              self.functions["\(webFunctionName)"] = generated_\(webFunctionName)_mcWebFunction
              """
              registrationStatements.append(registrationCode)
          }
          
          // 4. `super.init()` 호출과 함수 등록 코드를 포함한 새로운 `init` 메서드를 생성합니다.
          let combinedRegistrationCode = registrationStatements.joined(separator: "\n")
          
          let newInitDecl: DeclSyntax =
          """
          public init() {
              super.init(name: "\(raw: finalPluginName)")
              \(raw: combinedRegistrationCode)
          }
          """
          
          // 기존 init()이 있다면, 이를 삭제하는 로직을 추가할 수도 있습니다.
          // 현재 로직은 새로운 init()을 추가하는 방식입니다.
          
          return [newInitDecl]
      }
}

// 컴파일러 플러그인 설정
@main
struct McWebMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        McWebFunctionMacro.self, McWebPluginMacro.self
    ]
}
