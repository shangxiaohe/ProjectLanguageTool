//
//  ContentView.swift
//  ProjectLanguageTool
//
//  Created by xianliang.li on 2024/9/4.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import CoreXLSX
struct ContentView: View {
    
    @StateObject private var viewModel = HandleFileViewModel()
    @State private var showConfigPage = false
    @State private var showRecordPage: Bool = false
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(Color.gray)
                    
                VStack {
                    HStack {
                        Text("工程目录: ")
                            .foregroundColor(.white)
                        TextField("工程目录或者多语言目录", text: $viewModel.projectPath)
                            .frame(width: 400, height: 40)
                            .cornerRadius(10.0)
                        Button(action: {
                            openFile(type: 1)
                        }, label: {
                            Text("选择")
                        })
                    }
                    HStack {
                        Text("Excel文件:")
                            .foregroundColor(.white)
                        TextField("Excel文件", text: $viewModel.excelPath)
                            .frame(width: 400, height: 40)
                            .cornerRadius(10.0)
                        Button(action: {
                            openFile(type: 2)
                        }, label: {
                            Text("选择")
                        })
                    }
                    
                    HStack {
                        Button(action: {
                            showConfigPage.toggle()
                        }, label: {
                            Text("配置")
                        })
                        Button(action: {
                            viewModel.start()
                        }, label: {
                            Text("开始执行")
                        })
                    }
                    
                    ScrollView(.vertical) {
                        Text(self.viewModel.errorDes)
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }
 
                
            }
            .frame(width: 600, height: 400)
            
            if showConfigPage {
                ZStack {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color.black.opacity(0.95))
                    
                    HStack {
                        VStack {
                            ForEach(0..<self.viewModel.recordList.count, id: \.self) { index in
                                Button(action: {
                                    if let dic = viewModel.recordList[index] as? [String:Any] {
                                        self.viewModel.languageType = (dic["type"] as? Int) ?? 0
                                        if let languages = dic["language"] as? [String : String] {
                                            self.viewModel.customProjectLanguages = languages.map { (key: $0.key, value: $0.value) }
                                        }
                                    }
                                }, label: {
                                    ZStack {
                                        Color.white.opacity(0.1)
                                        if let dic = viewModel.recordList[index] as? [String:Any] {
                                            let text = (dic["name"] as? String) ?? ""
                                            Text(text.isEmpty ? "未命名" : text)
                                                .foregroundColor(.white)
                                        } else {
                                            Text("未命名")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(width: 80, height: 40)
                                })
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)

                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("多语言格式:")
                                    .foregroundColor(.white)
                                HStack(spacing:25) {
                                    Button(action: {
                                        self.viewModel.languageType = 0
                                    }, label: {
                                        HStack {
                                            Image(systemName: self.viewModel.languageType == 0 ? "circle.inset.filled" : "circle")
                                                .foregroundColor(.white)
                                            Text("strings")
                                                .foregroundColor(.white)
                                        }
                                    })
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        self.viewModel.languageType = 1
                                    } label: {
                                        HStack {
                                            Image(systemName: self.viewModel.languageType == 1 ? "circle.inset.filled" : "circle")
                                                .foregroundColor(.white)
                                            Text("json")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .buttonStyle(.plain)

                                }
                            }
                            VStack(spacing:5) {
                                ForEach(0..<self.viewModel.customProjectLanguages.count, id: \.self) { index in
                                    HStack {
                                        Text("多语言表\(index + 1):")
                                            .foregroundColor(.white)
                                        TextField("lang_en.json 或者 Localizable.strings", text: $viewModel.customProjectLanguages[index].key)
                                            .font(.system(size: 12))
                                            .onChange(of: viewModel.customProjectLanguages[index].key) {
                                                addNewRowIfNeeded()
                                            }
                                        Text(" : ")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18, weight: .bold))
                                            .offset(y: -2)
                                        TextField("翻译内容-中文", text: $viewModel.customProjectLanguages[index].value)
                                            .onChange(of: viewModel.customProjectLanguages[index].value) {
                                                addNewRowIfNeeded()
                                            }
                                    }
                                }
                            }
                            
                            HStack {
                                Button(action: {
                                    showRecordPage.toggle()
                                }, label: {
                                    Text("记录本地")
                                })
                                .alert("起个名字", isPresented: $showRecordPage) {
                                    TextField("请输入内容", text: $viewModel.recordName)
                                    Button("OK", action: {
                                        var list = UserDefaults.standard.array(forKey: "projectLanguageToolRecordKey") ?? []
                                        let tem = self.viewModel.customProjectLanguages
                                        var has: [(key: String, value: String)] = []
                                        for (_,t) in tem.enumerated() {
                                            if t.key.isEmpty == false && t.value.isEmpty == false {
                                                has.append(t)
                                            }
                                        }
                                        if has.isEmpty == false {
                                            let languageDic = Dictionary(uniqueKeysWithValues: has)
                                            list.append(["name": viewModel.recordName, "type" : self.viewModel.languageType, "language" : languageDic])
                                            UserDefaults.standard.setValue(list, forKey: "projectLanguageToolRecordKey")
                                            self.viewModel.recordList = list
                                        }
                                        
                                    })
                                    Button("Cancel", role: .cancel, action: {})
                                }

                                Button(action: {
                                    showConfigPage.toggle()
                                }, label: {
                                    Text("关闭")
                                })
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding()
                    }
                    
                }
                .frame(width: 550, height: 300)
            }
        }
        .padding()
        .alert(viewModel.alertText, isPresented: $viewModel.alert) {

        }
    }
    
    // 当最新的键值对都被填写时，添加新的空键值对
        private func addNewRowIfNeeded() {
            // 检查最后一对是否都已填写
            if let lastPair = self.viewModel.customProjectLanguages.last, !lastPair.key.isEmpty, !lastPair.value.isEmpty {
                self.viewModel.customProjectLanguages.append(("", "")) // 添加新的空行
            }
        }
    
    //MARK: 打开目录
    /// - Parameters:
    ///   - type: 1 工程目录 2 Exce目录
    private func openFile(type: Int) {
        let panel = NSOpenPanel()
        panel.title = "Choose a file"
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = type == 1 ? true : false
        panel.allowsMultipleSelection = false
        if type == 2 {
            if let excelUTType = UTType(filenameExtension: "xlsx") {
                panel.allowedContentTypes = [excelUTType]
            }
        }
        // 打开指定的初始目录
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                let path = url.absoluteString.replacingOccurrences(of: "file://", with: "")
                if type == 1 {
                    self.viewModel.projectPath = path
                } else {
                    self.viewModel.excelPath = path
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

class HandleFileViewModel: ObservableObject {
    
    @Published var recordList = UserDefaults.standard.array(forKey: "projectLanguageToolRecordKey") ?? []
    
    @Published var projectPath: String = ""
    @Published var excelPath: String = ""
    
    @Published var alert = false
    var alertText = ""
    
    @Published var errorDes = ""
    
    @Published var languageType = 0
    @Published var customProjectLanguages: [(key: String, value: String)] = [("","")]
    
    @Published var recordName = ""
    
    var projectLanguages: [String : String] = [:] // [多语言-国家:多语言表]
    var excelLanguages: [Int : String] = [:] //在excel中，第一行的列数对应的多语言-国家
    var excelLanguageList: [String : String] = [:] // [多语言-国家:多语言表]
    
    func start() {
        if customProjectLanguages.isEmpty || customProjectLanguages.first!.key.isEmpty {
            alertText = "请先配置信息"
            alert.toggle()
            return
        }
        if self.projectPath.isEmpty || self.excelPath.isEmpty {
            alertText = "工程目录 或者 Excel目录不能为空"
            alert.toggle()
            return
        }
        self.projectLanguages.removeAll()
        self.excelLanguages.removeAll()
        self.excelLanguageList.removeAll()
        analysisExcelFile()
        analysisProjectDirectory()
        
        if self.projectLanguages.isEmpty {
            alertText = "工程项目多语言文件获取失败"
            alert.toggle()
        }
        if (self.excelLanguageList.isEmpty) {
            alertText = "Excel文件解析失败"
            alert.toggle()
        }
        //开始写入文件
        writeFile()
    }
    
    //MARK: 写入文件
    func writeFile() {
        for (key, value) in self.projectLanguages {
            if let newJson = self.excelLanguageList[key] {
                writeFile(targetPath: value, targetStr: newJson)
            }
        }
        alertText = "执行完成"
        alert.toggle()
    }
    func writeFile(targetPath: String, targetStr: String) {
        if FileManager.default.fileExists(atPath: targetPath) {
            do {
                var fileContent = try String(contentsOfFile: targetPath, encoding: .utf8)
                if self.languageType == 0 {
                    var targetJson = "\n\n"
                    targetJson.append(targetStr)
                    targetJson.append("\n\n")
                    
                    fileContent.append(targetJson)
                } else {
                    while let last = fileContent.last, last.isWhitespace {
                        fileContent.removeLast()
                    }
                    guard fileContent.hasSuffix("}") else {
                        self.errorDes += "\(targetPath) 文件写入失败\n"
                        return
                    }
                    fileContent.removeLast()
                    
                    //判断去除"}"后，最后一个是不是",",不是则需要加上
                    while let last = fileContent.last, last.isWhitespace {
                        fileContent.removeLast()
                    }
                    if fileContent.hasSuffix(",") == false {
                        fileContent.append(",\n")
                    }
                    
                    var targetJson = "\n\n"
                    targetJson.append(targetStr)
                    targetJson.append("\n\n")
                    
                    fileContent.append(targetJson)
                    fileContent.append("}")
                }
                
                try fileContent.write(toFile: targetPath, atomically: true, encoding: .utf8)
            } catch {
                self.errorDes += "\(targetPath) 文件写入失败\n"
            }
        } else {
            self.errorDes += "\(targetPath) 文件不存在"
        }
    }
    
    //MARK: 解析project目录，获取多语言文件列表
    func analysisProjectDirectory() {
        handleProjectDirectory(path: self.projectPath)
    }
    func handleProjectDirectory(path: String) {
        if (self.languageType == 0) {
            for language in customProjectLanguages {
                if path.hasSuffix(language.key) {
                    let subPath = path + "/Localizable.strings"
                    if FileManager.default.fileExists(atPath: subPath) {
                        self.projectLanguages.updateValue(subPath, forKey: language.value)
                        return
                    }
                }
            }
        }
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue {
            do {
                let subpaths = try FileManager.default.subpathsOfDirectory(atPath: path)
                for subpath in subpaths {
                    handleProjectDirectory(path: path + subpath)
                }
            } catch {
                print("\n error = \(error)")
            }
        } else {
            for language in customProjectLanguages {
                if path.hasSuffix(language.key) {
                    self.projectLanguages.updateValue(path, forKey: language.value)
                    break
                }
            }
        }
    }
    
    //MARK: 解析excel文件
    func analysisExcelFile() {
        
        do {
            let filePath = self.excelPath
            guard let excelFile = XLSXFile(filepath: filePath) else {
                alertText = "Excel文件解析失败"
                alert.toggle()
                return
            }
            let parseSharedStrings = try excelFile.parseSharedStrings();
            for path in try excelFile.parseWorksheetPaths() {
                let worksheet = try excelFile.parseWorksheet(at: path)
                for row in worksheet.data?.rows ?? [] {
                    var key = ""
                    let _ = row.cells.map { cell in
                        if let content = cell.stringValue(parseSharedStrings!) {
                            if cell.reference.row <= 1 {
                                //第一行记录列数对应的国家语言
                                self.excelLanguages.updateValue(content, forKey: cell.reference.column.intValue)
                                self.excelLanguageList.updateValue("", forKey: content)
                            } else if cell.reference.column.intValue == 2 {
                                //第二列是key
                                key = content
                            } else {
                                if key.isEmpty == false {
                                    var json = self.excelLanguageList[(self.excelLanguages[cell.reference.column.intValue]!)] ?? ""
                                    if self.languageType == 0 {
                                        json.append("\"\(key)\" = \"\(content)\";\n")
                                    } else {
                                        json.append("\"\(key)\" : \"\(content)\",\n")
                                    }
                                    
                                    self.excelLanguageList.updateValue(json, forKey: (self.excelLanguages[cell.reference.column.intValue]!))
                                }
                            }
                        }
                    }
                }
            }
            
        } catch {
            alertText = "Excel文件解析失败"
            alert.toggle()
        }
    }
}
