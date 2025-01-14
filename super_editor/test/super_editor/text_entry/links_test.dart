import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_robots/flutter_test_robots.dart';
import 'package:flutter_test_runners/flutter_test_runners.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor/super_editor_test.dart';

import '../supereditor_test_tools.dart';

void main() {
  group('SuperEditor link editing >', () {
    testWidgetsOnAllPlatforms('recognizes a URL when typing and converts it to a link', (tester) async {
      await tester //
          .createDocument()
          .withSingleEmptyParagraph()
          .withInputSource(TextInputSource.ime)
          .pump();

      // Place the caret at the beginning of the empty document.
      await tester.placeCaretInParagraph("1", 0);

      // Type a URL. It shouldn't linkify until we add a space.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(0, text.text.length - 1),
        ),
        isEmpty,
      );

      // Type a space, to cause a linkify reaction.
      await tester.typeImeText(" ");

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com ");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(0, text.text.length - 2),
        ),
        isTrue,
      );
    });

    testWidgetsOnAllPlatforms(
        'recognizes a URL and converts it to a link when pressing ENTER at the end of a paragraph', (tester) async {
      final textContext = await tester //
          .createDocument()
          .withSingleEmptyParagraph()
          .withInputSource(TextInputSource.ime)
          .pump();

      // Place the caret at the beginning of the empty document.
      await tester.placeCaretInParagraph("1", 0);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(0, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new paragraph.
      await tester.pressEnter();

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(0, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty paragraph.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ParagraphNode>());
      expect((textContext.document.nodes[1] as ParagraphNode).text.text, "");
    });

    testWidgetsOnAllPlatforms(
        'recognizes a URL and converts it to a link when pressing ENTER at the middle of a paragraph', (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('Before link after link')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph(nodeId, 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and split the paragraph.
      await tester.pressEnter();

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the paragraph.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ParagraphNode>());
      expect((textContext.document.nodes[1] as ParagraphNode).text.text, "after link");
    });

    testWidgetsOnAndroid(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the end of a paragraph (on Android)',
        (tester) async {
      final textContext = await tester //
          .createDocument()
          .withSingleEmptyParagraph()
          .withInputSource(TextInputSource.ime)
          .pump();

      // Place the caret at the beginning of the empty document.
      await tester.placeCaretInParagraph("1", 0);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(0, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new paragraph.
      // On Android, pressing ENTER generates a "\n" insertion.
      await tester.typeImeText('\n');

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(0, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty paragraph.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ParagraphNode>());
      expect((textContext.document.nodes[1] as ParagraphNode).text.text, "");
    });

    testWidgetsOnAndroid(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the middle of a paragraph (on Android)',
        (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('Before link after link')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph(nodeId, 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and split the paragraph.
      // On Android, pressing ENTER generates a "\n" insertion.
      await tester.typeImeText('\n');

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the paragraph.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ParagraphNode>());
      expect((textContext.document.nodes[1] as ParagraphNode).text.text, "after link");
    });

    testWidgetsOnIos(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the end of a paragraph (on iOS)',
        (tester) async {
      final textContext = await tester //
          .createDocument()
          .withSingleEmptyParagraph()
          .withInputSource(TextInputSource.ime)
          .pump();

      // Place the caret at the beginning of the empty document.
      await tester.placeCaretInParagraph("1", 0);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(0, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new paragraph.
      // On iOS, pressing ENTER generates a newline action.
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pump();

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(0, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty line.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ParagraphNode>());
      expect((textContext.document.nodes[1] as ParagraphNode).text.text, "");
    });

    testWidgetsOnIos(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the middle of a paragraph (on iOS)',
        (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('Before link after link')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph(nodeId, 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and split the paragraph.
      // On iOS, pressing ENTER generates a newline action.
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pump();

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the paragraph.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ParagraphNode>());
      expect((textContext.document.nodes[1] as ParagraphNode).text.text, "after link");
    });

    testWidgetsOnAllPlatforms(
        'recognizes a URL and converts it to a link when pressing ENTER at the end of a list item', (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('* Item')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at the end of the list item.
      await tester.placeCaretInParagraph(nodeId, 4);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText(" https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Item https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(5, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new list item.
      await tester.pressEnter();

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Item https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(5, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty list item.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ListItemNode>());
      expect((textContext.document.nodes[1] as ListItemNode).text.text, "");
    });

    testWidgetsOnAllPlatforms(
        'recognizes a URL and converts it to a link when pressing ENTER at the middle of a list item', (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('* Before link after link')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph(nodeId, 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new list item.
      await tester.pressEnter();

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the list item.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ListItemNode>());
      expect((textContext.document.nodes[1] as ListItemNode).text.text, "after link");
    });

    testWidgetsOnAndroid(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the end of a list item (on Android)',
        (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('* Item')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at the end of the list item.
      await tester.placeCaretInParagraph(nodeId, 4);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText(" https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Item https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(5, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new list item.
      // On Android, pressing ENTER generates a "\n" insertion.
      await tester.typeImeText('\n');

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Item https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(5, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty list item.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ListItemNode>());
      expect((textContext.document.nodes[1] as ListItemNode).text.text, "");
    });

    testWidgetsOnAndroid(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the middle of a list item (on Android)',
        (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('* Before link after link')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph(nodeId, 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and split the list item.
      // On Android, pressing ENTER generates a "\n" insertion.
      await tester.typeImeText('\n');

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the list item.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ListItemNode>());
      expect((textContext.document.nodes[1] as ListItemNode).text.text, "after link");
    });

    testWidgetsOnIos(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the end of a list item (on iOS)',
        (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('* Item')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at the end of the list item.
      await tester.placeCaretInParagraph(nodeId, 4);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText(" https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Item https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(5, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new list item.
      // On iOS, pressing ENTER generates a newline action.
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pump();

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Item https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(5, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty list item.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ListItemNode>());
      expect((textContext.document.nodes[1] as ListItemNode).text.text, "");
    });

    testWidgetsOnIos(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the middle of a list item (on iOS)',
        (tester) async {
      final textContext = await tester //
          .createDocument()
          .fromMarkdown('* Before link after link')
          .withInputSource(TextInputSource.ime)
          .pump();

      final nodeId = textContext.document.nodes.first.id;

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph(nodeId, 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new list item.
      // On iOS, pressing ENTER generates a newline action.
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pump();

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the list item.
      expect(textContext.document.nodes.length, 2);
      expect(textContext.document.nodes[1], isA<ListItemNode>());
      expect((textContext.document.nodes[1] as ListItemNode).text.text, "after link");
    });

    testWidgetsOnAllPlatforms('recognizes a URL and converts it to a link when pressing ENTER at the end of a task',
        (tester) async {
      final document = MutableDocument(
        nodes: [
          TaskNode(id: "1", text: AttributedText("This is a task "), isComplete: false),
        ],
      );
      final composer = MutableDocumentComposer();
      final editor = createDefaultDocumentEditor(document: document, composer: composer);
      final task = document.getNodeAt(0) as TaskNode;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              editor: editor,
              document: document,
              composer: composer,
              componentBuilders: [
                TaskComponentBuilder(editor),
                ...defaultComponentBuilders,
              ],
            ),
          ),
        ),
      );

      // Place the caret at the end of the task.
      await tester.placeCaretInParagraph("1", 15);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = task.text;

      expect(text.text, "This is a task https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(15, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new task.
      await tester.pressEnter();

      // Ensure it's linkified.
      text = task.text;

      expect(text.text, "This is a task https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(15, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty task.
      expect(document.nodes.length, 2);
      expect(document.nodes[1], isA<TaskNode>());
      expect((document.nodes[1] as TaskNode).text.text, "");
    });

    testWidgetsOnAllPlatforms('recognizes a URL and converts it to a link when pressing ENTER at the middle of a task',
        (tester) async {
      final document = MutableDocument(
        nodes: [
          TaskNode(id: "1", text: AttributedText("Before link after link"), isComplete: false),
        ],
      );
      final composer = MutableDocumentComposer();
      final editor = createDefaultDocumentEditor(document: document, composer: composer);
      final task = document.getNodeAt(0) as TaskNode;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              editor: editor,
              document: document,
              composer: composer,
              componentBuilders: [
                TaskComponentBuilder(editor),
                ...defaultComponentBuilders,
              ],
            ),
          ),
        ),
      );

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph("1", 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = task.text;

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and split the task.
      await tester.pressEnter();

      // Ensure it's linkified.
      text = task.text;

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the task
      expect(document.nodes.length, 2);
      expect(document.nodes[1], isA<TaskNode>());
      expect((document.nodes[1] as TaskNode).text.text, "after link");
    });

    testWidgetsOnAndroid(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the end of a task (on Android)',
        (tester) async {
      final document = MutableDocument(
        nodes: [
          TaskNode(id: "1", text: AttributedText("This is a task "), isComplete: false),
        ],
      );
      final composer = MutableDocumentComposer();
      final editor = createDefaultDocumentEditor(document: document, composer: composer);
      final task = document.getNodeAt(0) as TaskNode;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              editor: editor,
              document: document,
              composer: composer,
              componentBuilders: [
                TaskComponentBuilder(editor),
                ...defaultComponentBuilders,
              ],
            ),
          ),
        ),
      );

      // Place the caret at the end of the task.
      await tester.placeCaretInParagraph("1", 15);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = task.text;

      expect(text.text, "This is a task https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(15, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new task.
      // On Android, pressing ENTER generates a "\n" insertion.
      await tester.typeImeText('\n');

      // Ensure it's linkified.
      text = task.text;

      expect(text.text, "This is a task https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(15, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty task.
      expect(document.nodes.length, 2);
      expect(document.nodes[1], isA<TaskNode>());
      expect((document.nodes[1] as TaskNode).text.text, "");
    });

    testWidgetsOnAndroid(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the middle of a task (on Android)',
        (tester) async {
      final document = MutableDocument(
        nodes: [
          TaskNode(id: "1", text: AttributedText("Before link after link"), isComplete: false),
        ],
      );
      final composer = MutableDocumentComposer();
      final editor = createDefaultDocumentEditor(document: document, composer: composer);
      final task = document.getNodeAt(0) as TaskNode;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              editor: editor,
              document: document,
              composer: composer,
              componentBuilders: [
                TaskComponentBuilder(editor),
                ...defaultComponentBuilders,
              ],
            ),
          ),
        ),
      );

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph("1", 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = task.text;

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new task.
      // On Android, pressing ENTER generates a "\n" insertion.
      await tester.typeImeText('\n');

      // Ensure it's linkified.
      text = task.text;

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the task.
      expect(document.nodes.length, 2);
      expect(document.nodes[1], isA<TaskNode>());
      expect((document.nodes[1] as TaskNode).text.text, "after link");
    });

    testWidgetsOnIos(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the end of a task (on iOS)',
        (tester) async {
      final document = MutableDocument(
        nodes: [
          TaskNode(id: "1", text: AttributedText("This is a task "), isComplete: false),
        ],
      );
      final composer = MutableDocumentComposer();
      final editor = createDefaultDocumentEditor(document: document, composer: composer);
      final task = document.getNodeAt(0) as TaskNode;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              editor: editor,
              document: document,
              composer: composer,
              componentBuilders: [
                TaskComponentBuilder(editor),
                ...defaultComponentBuilders,
              ],
            ),
          ),
        ),
      );

      // Place the caret at the end of the task.
      await tester.placeCaretInParagraph("1", 15);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = task.text;

      expect(text.text, "This is a task https://www.google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(15, text.text.length - 1),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and insert a new task.
      // On iOS, pressing ENTER generates a newline action.
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pump();

      // Ensure it's linkified.
      text = task.text;

      expect(text.text, "This is a task https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(15, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we added a new empty task.
      expect(document.nodes.length, 2);
      expect(document.nodes[1], isA<TaskNode>());
      expect((document.nodes[1] as TaskNode).text.text, "");
    });

    testWidgetsOnIos(
        'recognizes a URL and converts it to a link when pressing the newline button on the software keyboard at the middle of a task (on iOS)',
        (tester) async {
      final document = MutableDocument(
        nodes: [
          TaskNode(id: "1", text: AttributedText("Before link after link"), isComplete: false),
        ],
      );
      final composer = MutableDocumentComposer();
      final editor = createDefaultDocumentEditor(document: document, composer: composer);
      final task = document.getNodeAt(0) as TaskNode;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperEditor(
              editor: editor,
              document: document,
              composer: composer,
              componentBuilders: [
                TaskComponentBuilder(editor),
                ...defaultComponentBuilders,
              ],
            ),
          ),
        ),
      );

      // Place the caret at "Before link |after link".
      await tester.placeCaretInParagraph("1", 12);

      // Type a URL. It shouldn't linkify until the user presses ENTER.
      await tester.typeImeText("https://www.google.com");

      // Ensure it's not linkified yet.
      var text = task.text;

      expect(text.text, "Before link https://www.google.comafter link");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: const SpanRange(12, 34),
        ),
        isEmpty,
      );

      // Press enter to linkify the URL and split the task.
      // On iOS, pressing ENTER generates a newline action.
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pump();

      // Ensure it's linkified.
      text = task.text;

      expect(text.text, "Before link https://www.google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(12, text.text.length - 1),
        ),
        isTrue,
      );

      // Ensure we split the task.
      expect(document.nodes.length, 2);
      expect(document.nodes[1], isA<TaskNode>());
      expect((document.nodes[1] as TaskNode).text.text, "after link");
    });

    testWidgetsOnAllPlatforms('recognizes a second URL when typing and converts it to a link', (tester) async {
      await tester //
          .createDocument()
          .withSingleEmptyParagraph()
          .withInputSource(TextInputSource.ime)
          .pump();

      // Place the caret at the beginning of the empty document.
      await tester.placeCaretInParagraph("1", 0);

      // Type text with two URLs
      await tester.typeImeText("https://www.google.com and https://flutter.dev ");

      // Ensure both URLs are linkified with the correct URLs.
      final text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "https://www.google.com and https://flutter.dev ");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: const SpanRange(0, 21),
        ),
        isTrue,
      );

      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://flutter.dev")),
          },
          range: const SpanRange(27, 45),
        ),
        isTrue,
      );
    });

    testWidgetsOnAllPlatforms('recognizes a URL without www and converts it to a link', (tester) async {
      await tester //
          .createDocument()
          .withSingleEmptyParagraph()
          .withInputSource(TextInputSource.ime)
          .pump();

      // Place the caret at the beginning of the empty document.
      await tester.placeCaretInParagraph("1", 0);

      // Type a URL without the www. It shouldn't linkify until we add a space.
      await tester.typeImeText("google.com");

      // Ensure it's not linkified yet.
      var text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "google.com");
      expect(
        text.getAttributionSpansInRange(
          attributionFilter: (attribution) => true,
          range: SpanRange(0, text.text.length - 1),
        ),
        isEmpty,
      );

      // Type a space, to cause a linkify reaction.
      await tester.typeImeText(" ");

      // Ensure it's linkified.
      text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "google.com ");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://google.com")),
          },
          range: SpanRange(0, text.text.length - 2),
        ),
        isTrue,
      );
    });

    testWidgetsOnAllPlatforms('inserts https scheme if it is missing', (tester) async {
      await tester //
          .createDocument()
          .withSingleEmptyParagraph()
          .withInputSource(TextInputSource.ime)
          .pump();

      // Place the caret at the beginning of the empty document.
      await tester.placeCaretInParagraph("1", 0);

      // Type a URL. It shouldn't linkify until we add a space.
      await tester.typeImeText("www.google.com");

      // Type a space, to cause a linkify reaction.
      await tester.typeImeText(" ");

      // Ensure it's linkified with a URL schema.
      var text = SuperEditorInspector.findTextInParagraph("1");
      text = SuperEditorInspector.findTextInParagraph("1");

      expect(text.text, "www.google.com ");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("https://www.google.com")),
          },
          range: SpanRange(0, text.text.length - 2),
        ),
        isTrue,
      );
    });

    testWidgetsOnAllPlatforms('does not expand the link when inserting before the link', (tester) async {
      // Configure and render a document.
      await tester //
          .createDocument()
          .fromMarkdown("[www.google.com](www.google.com)")
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Place the caret in the first paragraph at the start of the link.
      await tester.placeCaretInParagraph(doc.nodes.first.id, 0);

      // Type some text by simulating hardware keyboard key presses.
      await tester.typeKeyboardText('Go to ');

      // Ensure that the link is unchanged
      expect(
        SuperEditorInspector.findDocument(),
        equalsMarkdown("Go to [www.google.com](www.google.com)"),
      );
    });

    testWidgets('does not expand the link when inserting after the link', (tester) async {
      // Configure and render a document.
      await tester //
          .createDocument()
          .fromMarkdown("[www.google.com](www.google.com)")
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Place the caret in the first paragraph at the start of the link.
      await tester.placeCaretInParagraph(doc.nodes.first.id, 14);

      // Type some text by simulating hardware keyboard key presses.
      await tester.typeKeyboardText(' to learn anything');

      // Ensure that the link is unchanged
      expect(
        SuperEditorInspector.findDocument(),
        equalsMarkdown("[www.google.com](www.google.com) to learn anything"),
      );
    });

    testWidgetsOnAllPlatforms('can insert characters in the middle of a link', (tester) async {
      await tester //
          .createDocument()
          .fromMarkdown("[www.google.com](www.google.com)")
          .withInputSource(TextInputSource.ime)
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Place the caret at "www.goog|le.com"
      await tester.placeCaretInParagraph(doc.nodes.first.id, 8);

      // Add characters.
      await tester.typeImeText("oooo");

      // Ensure the characters were inserted, the whole link is still attributed.
      final nodeId = doc.nodes.first.id;
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "www.googoooole.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("www.google.com")),
          },
          range: SpanRange(0, text.text.length - 1),
        ),
        isTrue,
      );
    });

    testWidgetsOnAllPlatforms('user can delete characters at the beginning of a link', (tester) async {
      await tester //
          .createDocument()
          .fromMarkdown("[www.google.com](www.google.com)")
          .withInputSource(TextInputSource.ime)
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Place the caret at "|www.google.com"
      await tester.placeCaretInParagraph(doc.nodes.first.id, 0);

      // Delete downstream characters.
      await tester.pressDelete();
      await tester.pressDelete();
      await tester.pressDelete();
      await tester.pressDelete();

      // Ensure the characters were inserted, the whole link is still attributed.
      final nodeId = doc.nodes.first.id;
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "google.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("www.google.com")),
          },
          range: SpanRange(0, text.text.length - 1),
        ),
        isTrue,
      );
    });

    testWidgetsOnAllPlatforms('user can delete characters in the middle of a link', (tester) async {
      await tester //
          .createDocument()
          .fromMarkdown("[www.google.com](www.google.com)")
          .withInputSource(TextInputSource.ime)
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Place the caret at "www.google.com|"
      await tester.placeCaretInParagraph(doc.nodes.first.id, 10);

      // Delete upstream characters.
      await tester.pressBackspace();
      await tester.pressBackspace();
      await tester.pressBackspace();
      await tester.pressBackspace();
      await tester.pressBackspace();

      // Ensure the characters were inserted, the whole link is still attributed.
      final nodeId = doc.nodes.first.id;
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "www.g.com");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("www.google.com")),
          },
          range: SpanRange(0, text.text.length - 1),
        ),
        isTrue,
      );
    });

    testWidgetsOnAllPlatforms('user can delete characters at the end of a link', (tester) async {
      await tester //
          .createDocument()
          .fromMarkdown("[www.google.com](www.google.com)")
          .withInputSource(TextInputSource.ime)
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Place the caret at "www.google.com|"
      await tester.placeCaretInParagraph(doc.nodes.first.id, 14);

      // Delete upstream characters.
      await tester.pressBackspace();
      await tester.pressBackspace();
      await tester.pressBackspace();
      await tester.pressBackspace();

      // Ensure the characters were inserted, the whole link is still attributed.
      final nodeId = doc.nodes.first.id;
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "www.google");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("www.google.com")),
          },
          range: SpanRange(0, text.text.length - 1),
        ),
        isTrue,
      );
    });

    testWidgetsOnAllPlatforms('user can delete characters at the end of a link and then keep typing', (tester) async {
      await tester //
          .createDocument()
          .fromMarkdown("[www.google.com](www.google.com)")
          .withInputSource(TextInputSource.ime)
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Place the caret at "www.google.com|"
      await tester.placeCaretInParagraph(doc.nodes.first.id, 14);

      // Delete a character at the end of the link.
      await tester.pressBackspace();

      // Start typing new content, which shouldn't become part of the link.
      await tester.typeImeText(" hello");

      // Ensure the text were inserted, and only the URL is linkified.
      final nodeId = doc.nodes.first.id;
      var text = SuperEditorInspector.findTextInParagraph(nodeId);

      expect(text.text, "www.google.co hello");
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("www.google.com")),
          },
          range: const SpanRange(0, 12),
        ),
        isTrue,
      );
      expect(
        text.hasAttributionsThroughout(
          attributions: {
            LinkAttribution(url: Uri.parse("www.google.com")),
          },
          range: SpanRange(13, text.text.length - 1),
        ),
        isFalse,
      );
    });

    testWidgetsOnAllPlatforms('does not extend link to new paragraph', (tester) async {
      await tester //
          .createDocument()
          .fromMarkdown("[www.google.com](www.google.com)")
          .withInputSource(TextInputSource.ime)
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Place the caret at "www.google.com|".
      await tester.placeCaretInParagraph(doc.nodes.first.id, 14);

      // Create a new paragraph.
      await tester.pressEnter();

      // We had an issue where link attributions were extended to the beginning of
      // an empty paragraph, but were removed after the user started typing. So, first,
      // ensure that no link markers were added to the empty paragraph.
      expect(doc.nodes.length, 2);
      final newParagraphId = doc.nodes[1].id;
      AttributedText newParagraphText = SuperEditorInspector.findTextInParagraph(newParagraphId);
      expect(newParagraphText.spans.markers, isEmpty);

      // Type some text.
      await tester.typeImeText("New paragraph");

      // Ensure the text we typed didn't re-introduce a link attribution.
      newParagraphText = SuperEditorInspector.findTextInParagraph(newParagraphId);
      expect(newParagraphText.text, "New paragraph");
      expect(
        newParagraphText.getAttributionSpansInRange(
          attributionFilter: (a) => a is LinkAttribution,
          range: SpanRange(0, newParagraphText.text.length - 1),
        ),
        isEmpty,
      );
    });

    testWidgetsOnAllPlatforms('does not extend link to new list item', (tester) async {
      await tester //
          .createDocument()
          .fromMarkdown(" * [www.google.com](www.google.com)")
          .withInputSource(TextInputSource.ime)
          .pump();

      final doc = SuperEditorInspector.findDocument()!;

      // Ensure the Markdown correctly created a list item.
      expect(doc.nodes.first, isA<ListItemNode>());

      // Place the caret at "www.google.com|".
      await tester.placeCaretInParagraph(doc.nodes.first.id, 14);

      // Create a new list item.
      await tester.pressEnter();

      // We had an issue where link attributions were extended to the beginning of
      // an empty list item, but were removed after the user started typing. So, first,
      // ensure that no link markers were added to the empty list item.
      expect(doc.nodes.length, 2);
      expect(doc.nodes[1], isA<ListItemNode>());
      final newListItemId = doc.nodes[1].id;
      AttributedText newListItemText = SuperEditorInspector.findTextInParagraph(newListItemId);
      expect(newListItemText.spans.markers, isEmpty);

      // Type some text.
      await tester.typeImeText("New list item");

      // Ensure the text we typed didn't re-introduce a link attribution.
      newListItemText = SuperEditorInspector.findTextInParagraph(newListItemId);
      expect(newListItemText.text, "New list item");
      expect(
        newListItemText.getAttributionSpansInRange(
          attributionFilter: (a) => a is LinkAttribution,
          range: SpanRange(0, newListItemText.text.length - 1),
        ),
        isEmpty,
      );
    });

    // TODO: once it's easier to configure task components (#1295), add a test that checks link attributions when inserting a new task
  });
}
