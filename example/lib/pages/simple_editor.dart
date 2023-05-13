import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class SimpleEditor extends StatelessWidget {
  SimpleEditor({
    super.key,
    required this.jsonString,
    required this.themeData,
    required this.onEditorStateChange,
  });

  final Future<String> jsonString;
  final ThemeData themeData;
  final void Function(EditorState editorState) onEditorStateChange;
  ToolbarItemValidator _onlyShowInSingleTextSelection = (editorState) {
    final nodes = editorState.service.selectionService.currentSelectedNodes
        .whereType<TextNode>()
        .where(
          (textNode) =>
              BuiltInAttributeKey.globalStyleKeys.contains(textNode.subtype) ||
              textNode.subtype == null,
        );
    if (!nodes.isNotEmpty) {
      return false;
    }
    final nodes2 = editorState.service.selectionService.currentSelectedNodes;
    return (nodes2.length == 1 && nodes2.first is TextNode);
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: jsonString,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          final editorState = EditorState(
            document: Document.fromJson(
              Map<String, Object>.from(
                json.decode(snapshot.data!),
              ),
            ),
          );
          editorState.logConfiguration
            ..handler = debugPrint
            ..level = LogLevel.all;
          onEditorStateChange(editorState);
          return AppFlowyEditor(
              editable: true,
              editorState: editorState,
              themeData: themeData,
              autoFocus: editorState.document.isEmpty,
              showDefaultToolbar: false,
              toolbarItems: [
                ToolbarItem(
                  id: 'id',
                  type: 1,
                  validator: _onlyShowInSingleTextSelection,
                  itemBuilder: (context, editorState) => GestureDetector(
                    onTap: () {
                      final textNodes = editorState
                          .service.selectionService.currentSelectedNodes
                          .whereType<TextNode>()
                          .toList();
                      final test = editorState.getTextInSelection(
                          textNodes,
                          editorState
                              .getSelection(editorState.cursorSelection));

                      Log.editor.info('++++++++++++++++++++++++ test $test');
                    },
                    child: Row(
                      children: const [
                        Icon(
                          Icons.download,
                          weight: 20,
                          color: Colors.red,
                        ),
                        Text(
                          'Add Tag',
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ]);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
