
struct StackDecorator<Element> {

    var array: [Element]

    var isEmpty: Bool {
        return array.isEmpty
    }

    var isNotEmpty: Bool {
        return array.isNotEmpty
    }

    var peek: Element? {
        return array.last
    }

    init(_ array: [Element] = []) {
        self.array = array
    }

    mutating func push(_ element: Element) {
        array.append(element)
    }

    mutating func pop() -> Element {
        return array.removeLast()
    }

    mutating func update(with closure: (inout Element) throws -> ()) rethrows {
        try closure(&array[array.count - 1])
    }

}

func throwError<T>(_ error: @autoclosure () -> Error) throws -> T {
    fatalError("boi")
    throw error()
}

