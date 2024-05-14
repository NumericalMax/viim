import Foundation
import CoreTransferable
import UniformTypeIdentifiers

extension VisualAcuityTest {
    struct TestOutputWithSurvey: Codable {
        private static let fileNameDateFormatter: ISO8601DateFormatter = {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions.remove(.withColonSeparatorInTime)
            dateFormatter.formatOptions.remove(.withColonSeparatorInTimeZone)
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter
        }()

        let test: TestOutput
        let survey: [String: String]

        var fileName: String {
            "VisualAcuityTest-Output-\(Self.fileNameDateFormatter.string(from: test.startedAt))"
        }
    }
}

extension VisualAcuityTest.TestOutputWithSurvey: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: VisualAcuityTest.TestOutputWithSurvey.self, contentType: .testOutput)

        FileRepresentation(exportedContentType: .testOutput) { output in
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent(output.fileName)
                .appendingPathExtension("json")

            let data = try JSONEncoder().encode(output)
            do {
                try data.write(to: fileURL)
                print("🍏 successfully saved to ", fileURL)
            } catch {
                print("🍎", error)
            }

            return SentTransferredFile(fileURL)
        }
    }
}

extension UTType {
    static var testOutput = UTType(exportedAs: "de.tum.cit.ase.EyeSquintingTest.TestOutput")
}
