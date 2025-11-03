// The Swift Programming Language
// https://docs.swift.org/swift-book
/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
//@freestanding(expression)
//public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "McWebAnnotationMacros", type: "StringifyMacro")

@attached(peer, names: arbitrary) // 'arbitrary'는 생성될 선언의 이름을 미리 알 수 없을 때 사용
public macro McWebMethod(name: String? = nil) = #externalMacro(module: "McWebAnnotationMacros", type: "McWebFunctionMacro")


@attached(member, names: arbitrary) // 'arbitrary'는 생성될 선언의 이름을 미리 알 수 없을 때 사용
public macro McWebPlugin(name: String? = nil) = #externalMacro(module: "McWebAnnotationMacros", type: "McWebPluginMacro")
