import Foundation

struct ExportSummary: Codable {
    let id: String
    let passes: [UUID]
    let startedAt: Date
    let distance: Decimal
    let blendShapes: [String]
    let survey: [String: String]
}

struct ExportPass: Codable {
    let id: UUID
    let options: VisualAcuityTest.TestPassOptions
    let result: VisualAcuityTest.TestPassResult
    let samples: [UUID]
    let charactersWithTimestamp: [ExportCharacterData]
}

struct ExportCharacterData: Codable {
    let characters: [String]
    let startedAt: Int64
    let logMAR: Decimal

    init(fromRow row: CharacterRow) {
        characters = row.characters
        startedAt = row.startedAt
        logMAR = row.logMAR
    }
}

struct ExportSample: Codable {
    let id: UUID
    let trackingSample: VisualAcuityTest.TrackingSample
}

extension VisualAcuityTest.TestOutputWithSurvey {
    func export(withIdentifier id: String) throws {
        if
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let pass1 = test.passes.first,
            let pass2 = test.passes.last
        {
            let directoryURL = documentsDirectory.appending(component: fileName + "/")
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: false)

            let exportPass1 = try exportPass(pass1, to: directoryURL)
            let exportPass2 = try exportPass(pass2, to: directoryURL)
            let exportSummary = ExportSummary(
                id: id,
                passes: [exportPass1.id, exportPass2.id],
                startedAt: test.startedAt,
                distance: test.distance,
                blendShapes: test.blendShapes,
                survey: survey
            )
            let encoder = JSONEncoder()
            let summaryData = try encoder.encode(exportSummary)
            try summaryData.write(
                to: directoryURL
                    .appending(component: "summary-\(id)")
                    .appendingPathExtension("json")
            )
        }
    }

    private func exportPass(_ pass: VisualAcuityTest.TestPassOutput, to directoryURL: URL) throws -> ExportPass {
        let encoder = JSONEncoder()
        var sampleIDs: [UUID] = []

        for sample in pass.samples {
            let id = UUID()
            sampleIDs.append(id)
            let exportSample = ExportSample(id: id, trackingSample: sample)
            // save to file
            let sampleURL = directoryURL.appending(component: id.uuidString).appendingPathExtension("json")
            let data = try encoder.encode(exportSample)
            try data.write(to: sampleURL)
        }

        let exportPass = ExportPass(
            id: UUID(),
            options: pass.options,
            result: pass.result,
            samples: sampleIDs,
            charactersWithTimestamp: pass.result.characters.map {
                ExportCharacterData(fromRow: $0)
            }
        )

        let exportPassData = try encoder.encode(exportPass)
        try exportPassData.write(
            to: directoryURL
                .appending(component: "summary-pass-\(exportPass.id.uuidString)")
                .appendingPathExtension("json")
        )

        return exportPass
    }
}
