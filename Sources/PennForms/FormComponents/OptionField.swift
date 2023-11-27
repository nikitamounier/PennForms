import SwiftUI

struct OptionField<Option: Hashable>: FormComponent {
    @Binding var selection: Option?
    let options: [Option]
    let toString: (Option) -> String
    let title: String?
    let placeholder: String?
    
    @Environment(\.validator) var validator
    
    init(_ selection: Binding<Option?>, options: [Option], toString: @escaping (Option) -> String, title: String? = nil, placeholder: String? = nil) {
        self._selection = selection
        self.options = options
        self.toString = toString
        self.title = title
        self.placeholder = placeholder
    }
    
    init(_ selection: Binding<Option?>, options: [Option], title: String? = nil, placeholder: String? = nil) where Option: CaseIterable, Option: RawRepresentable<String> {
        self._selection = selection
        self.options = options
        self.toString = { $0.rawValue }
        self.title = title
        self.placeholder = placeholder
    }
    
    init(_ selection: Binding<Option?>, range: ClosedRange<Int>, title: String? = nil, placeholder: String? = nil) where Option == Int, Option: LosslessStringConvertible {
        self._selection = selection
        self.options = Array(range)
        self.toString = { $0.description }
        self.title = title
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .bold()
            }
            Picker("", selection: $selection) {
                Text(" ")
                    .tag(nil as Option?)
                ForEach(options, id: \.self) { option in
                    Text(toString(option))
                        .tag(option as Option?)
                }
            }
            .customPickerStyle(
                labelText: selection == nil ? nil : toString(selection!), placeholder: placeholder, width: 200, isValid: validator.isValid(selection as AnyValidator.Input)
            )
            if !validator.isValid(selection as AnyValidator.Input), let message = validator.message {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle")
                    Text(message)
                }
                .foregroundColor(.red)
            }
        }
    }
}

struct CustomPickerStyle: ViewModifier {
    var labelText: String?
    let placeholder: String?
    var width: CGFloat
    let isValid: Bool
    
    func body(content: Content) -> some View {
        Menu {
            content
        } label: {
            HStack {
                Text(labelText ?? placeholder ?? " ")
                    .foregroundStyle(labelText == nil ? .secondary : .primary)
                Spacer()
                Image(systemName: "chevron.up")
                    .resizable()
                    .frame(width: 12, height: 8)
                    .rotationEffect(.degrees(180))
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: width, alignment: .leading)
        .padding()
        .background(.background)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isValid ? Color.secondary.opacity(0.3): Color.red , lineWidth: 2)
        )
    }
}

extension View {
    func customPickerStyle(labelText: String?, placeholder: String? = nil, width: CGFloat, isValid: Bool) -> some View {
        self.modifier(CustomPickerStyle(labelText: labelText, placeholder: placeholder, width: width, isValid: isValid))
    }
}
