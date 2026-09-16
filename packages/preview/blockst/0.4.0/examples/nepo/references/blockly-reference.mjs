// An independent reference rendering of the six prototype blocks.
//
// This is a second, deliberately separate transcription of Open Roberta's
// renderer — `core/block_render_svg.js`, functions `renderCompute_`,
// `renderDrawTop_`, `renderDrawRight_`, `renderDrawBottom_` and
// `renderDrawLeft_`. The Rust plugin is a third. Comparing the two is how the
// prototype checks its geometry without having Open Roberta Lab to hand: a
// mistake would have to be made identically, twice, in two languages, from the
// same source, to slip through.
//
// The block descriptions below are written from the official block definitions
// (blocks/mbedControls.js, blocks/mbedActions.js, blocks/mbedImage.js,
// blocks/robControls.js, blocks/robSensorDefinitions.js), NOT from the
// catalog in scripts/nepo-wasm/data — so the catalog is under test too.
//
//   node examples/nepo/references/blockly-reference.mjs > reference.json

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const fixtures = JSON.parse(readFileSync(join(here, 'fixtures.json'), 'utf8'));

// --- Blockly.BlockSvg constants, verbatim -------------------------------

const SEP_SPACE_X = 10;
const SEP_SPACE_Y = 10;
const INLINE_PADDING_Y = 5;
const MIN_BLOCK_Y = 25;
const TAB_HEIGHT = 20;
const TAB_WIDTH = 8;
const NOTCH_WIDTH = 30;
const CORNER_RADIUS = 2;
const FIELD_HEIGHT = 25;
// Blockly.Icon.prototype.SIZE. A mutator icon is not a field: `render()` walks
// the icons first and hands `renderCompute_` the width they claimed.
const ICON_SIZE = 17;

const NOTCH_PATH_LEFT = 'h 2.5l 5, 5 5, -5 h 2.5';
const NOTCH_PATH_RIGHT = 'h -3.5l -4, 4 -4, -4 h -3.5';
const TOP_LEFT_CORNER_START = 'm 0,' + CORNER_RADIUS;
const TOP_LEFT_CORNER =
  'A ' + CORNER_RADIUS + ',' + CORNER_RADIUS + ' 0 0,1 ' + CORNER_RADIUS + ',0';
const INNER_TOP_LEFT_CORNER =
  NOTCH_PATH_RIGHT + ' h -' + (NOTCH_WIDTH - 15 + 1 - CORNER_RADIUS) +
  ' a ' + CORNER_RADIUS + ',' + CORNER_RADIUS + ' 0 0,0 -' + CORNER_RADIUS + ',' + CORNER_RADIUS;
const INNER_BOTTOM_LEFT_CORNER =
  'a ' + CORNER_RADIUS + ',' + CORNER_RADIUS + ' 0 0,0 ' + CORNER_RADIUS + ',' + CORNER_RADIUS;
const TAB_PATH_DOWN_INNER =
  'v 4.1 l-5.154 -0.469c0 0 -1.096 3.125 -1.33 4.656s-0.25 3.703 0.406 5.078s ' +
  '1.984 2.688 3.484 2.953s2.375 0.203 2.594 0.219 v 3.5';
const TAB_PATH_DOWN_OUTER =
  'v -5 c-4.217 0.097 -4.471 -0.54 -5.281 -1.609c-1.109 -1.46 -1.159 -3.82 ' +
  '-0.159 -7.12l0.33 -1.061l5.11 0.44 v -5.2';

// --- Blocks, from the official definitions ------------------------------

const W = fixtures.widths;
const label = (text) => ({ width: W[text], editable: false });
const dropdown = (text) => ({ width: W[text], editable: true });
const textField = (text) => ({ width: W[text], editable: true });
// FieldColour has no text, but the visual swatch is 22px wide.  The regular
// field-box padding supplies 10px of that width, leaving twelve pixels of field
// width for the layout pass.
const colourField = () => ({ width: 12, editable: true });
const pixel = () => ({ width: 16, editable: true });
// FieldDropdownImage(options, path, 24, 24): `size_` is the picture plus ten
// pixels for the arrow, and plus INLINE_PADDING_Y above and below. It is the
// only field here that is taller than Blockly's default 25, and the row it
// sits in has to grow with it.
const imageDropdown = () => ({ width: 34, height: 34, editable: true });
const icon = () => ({ width: 12, editable: false });

const textBlock = () => ({
  shape: 'value', check: 'String',
  // blocks/text.js places a 12px opening quote image and a matching closing
  // image around FieldTextInput.
  rows: [{ type: 'dummy', align: 'left', fields: [icon(), textField('Hallo'), icon()] }],
});

const colourBlock = () => ({
  shape: 'value', check: 'Colour',
  rows: [{ type: 'dummy', align: 'left', fields: [colourField()] }],
});

// blocks/mbedImage.js: one monospace column ruler plus five rows of a row
// label and five FieldPixelbox fields, every row right-aligned.
const imageBlock = () => {
  const rows = [];
  const ruler = [label('0')];
  for (let i = 1; i < 5; i++) ruler.push(label('  ' + i));
  rows.push({ type: 'dummy', align: 'right', fields: ruler });
  for (let i = 0; i < 5; i++) {
    const fields = [label(String(i))];
    for (let j = 0; j < 5; j++) fields.push(pixel());
    rows.push({ type: 'dummy', align: 'right', fields });
  }
  return { shape: 'value', check: 'Image', rows };
};

// blocks/variables.js: `robGlobalVariables_declare` is one value input
// carrying VARIABLES_TITLE, a FieldTextInput for the name, ':', the type
// dropdown and the arrow — plus the minus mutator its init installs.
const declareBlock = () => ({
  shape: 'statement',
  icons: 1,
  rows: [{
    type: 'value', align: 'left', check: 'Number',
    fields: [
      label('Variable'), textField('Punkte'), label(':'),
      dropdown('Zahl ▾'), label('←'),
    ],
    target: numberBlock(),
  }],
});

const numberBlock = () => ({
  shape: 'value', check: 'Number',
  rows: [{ type: 'dummy', align: 'left', fields: [textField('0')] }],
});

const keySensorBlock = () => ({
  shape: 'value', check: 'Boolean',
  rows: [{
    type: 'dummy', align: 'left',
    fields: [label('Taste'), dropdown('A ▾'), label('gedrückt?')],
  }],
});

const BLOCKS = {
  // robControls_start: dummy row, no previous connection. Its two-space
  // FieldLabel precedes the hidden DEBUG field in the official definition,
  // and `setMutatorPlus` gives it the icon that declares variables.
  robControls_start: () => ({
    shape: 'start',
    icons: 1,
    rows: [{ type: 'dummy', align: 'left', fields: [label('Start'), label('  ')] }],
  }),
  // The same block after the plus was used once: `updateShape_` appends the
  // statement input ST, which only `declarationGlobal` notches may enter.
  robControls_start_declare: () => ({
    shape: 'start',
    icons: 1,
    rows: [
      { type: 'dummy', align: 'left', fields: [label('Start'), label('  ')] },
      { type: 'statement', align: 'left', fields: [], stack: [declareBlock()] },
    ],
  }),
  robGlobalVariables_declare: declareBlock,
  // robControls_if before any mutation: one Boolean value row and one mouth.
  robControls_if: () => ({
    shape: 'statement',
    icons: 1,
    rows: [
      {
        type: 'value', align: 'left', check: 'Boolean',
        fields: [label('wenn')], target: keySensorBlock(),
      },
      {
        type: 'statement', align: 'left', fields: [label('mache')],
        stack: [BLOCKS.mbedActions_display_text()],
      },
    ],
  }),
  // mbedActions_display_text: appendValueInput('OUT') + two fields.
  mbedActions_display_text: () => ({
    shape: 'statement',
    rows: [{
      type: 'value', align: 'left', check: 'String',
      fields: [label('Zeige'), dropdown('Text ▾')],
      target: textBlock(),
    }],
  }),
  mbedActions_display_text_empty: () => ({
    shape: 'statement',
    rows: [{
      type: 'value', align: 'left', check: 'String',
      fields: [label('Zeige'), dropdown('Text ▾')],
    }],
  }),
  actions_rgbLed_hidden_on_calliope: () => ({
    shape: 'statement',
    rows: [{
      type: 'value', align: 'left', check: 'Colour',
      fields: [label('Schalte RGB LED an Farbe')],
      target: colourBlock(),
    }],
  }),
  // robSensors.js: title, port dropdown, "gedrückt?" — Boolean out.
  robSensors_key_getSample: () => ({
    shape: 'value', check: 'Boolean',
    rows: [{
      type: 'dummy', align: 'left',
      fields: [label('Taste'), dropdown('A ▾'), label('gedrückt?')],
    }],
  }),
  // robControls_loopForever: title row plus a statement row labelled "mache".
  robControls_loopForever: () => ({
    shape: 'statement',
    rows: [
      { type: 'dummy', align: 'left', fields: [label('Wiederhole unendlich oft')] },
      {
        type: 'statement', align: 'left', fields: [label('mache')],
        stack: [BLOCKS.mbedActions_display_text()],
      },
    ],
  }),
  // blocks/mbedImage.js: one dummy input holding nothing but the picture
  // dropdown, so the block is exactly that field plus its padding.
  mbedImage_get_image: () => ({
    shape: 'value', check: 'Image',
    rows: [{ type: 'dummy', align: 'left', fields: [imageDropdown()] }],
  }),
  // The action block that holds one: its row has to grow to the picture.
  mbedActions_display_image: () => ({
    shape: 'statement',
    rows: [{
      type: 'value', align: 'left', check: 'Image',
      fields: [label('Zeige'), dropdown('Bild ▾')],
      target: BLOCKS.mbedImage_get_image(),
    }],
  }),
  mbedImage_image: () => ({
    shape: 'statement',
    rows: [{
      type: 'value', align: 'left', check: 'Image',
      fields: [label('Zeige'), dropdown('Bild ▾')],
      target: imageBlock(),
    }],
  }),
};

// --- renderCompute_ ------------------------------------------------------

function connections(shape) {
  if (shape === 'start') return { previous: false, next: true, output: false };
  if (shape === 'value') return { previous: false, next: false, output: true };
  if (shape === 'cap') return { previous: true, next: false, output: false };
  return { previous: true, next: true, output: false };
}

function stackHeightWidth(stack) {
  let height = 0;
  let width = 0;
  stack.forEach((block, index) => {
    const rendered = render(block, index > 0, index + 1 < stack.length);
    width = Math.max(width, rendered.width);
    height += rendered.height;
    if (index > 0) height -= 4; // getHeightWidth: minus the tab
  });
  return { height, width };
}

function render(block, connectedAbove, connectedBelow) {
  const conn = connections(block.shape);

  // Blockly.BlockSvg.render(): cursorX starts at SEP_SPACE_X, every icon
  // advances it by SIZE + SEP_SPACE_X, and the leading SEP_SPACE_X is taken
  // back afterwards. What is left is how far the first row has to move over.
  let iconWidth = SEP_SPACE_X;
  for (let i = 0; i < (block.icons || 0); i++) iconWidth += ICON_SIZE + SEP_SPACE_X;
  iconWidth -= SEP_SPACE_X;

  let rightEdge = iconWidth + SEP_SPACE_X * 2;
  if (conn.previous || conn.next) {
    rightEdge = Math.max(rightEdge, NOTCH_WIDTH + SEP_SPACE_X);
  }

  let fieldValueWidth = 0;
  let fieldStatementWidth = 0;
  let hasValue = false;
  let hasStatement = false;
  let hasDummy = false;

  const rows = block.rows.map((row, index) => {
    let renderHeight = MIN_BLOCK_Y;
    let child = null;
    let stack = null;
    if (row.target) {
      child = render(row.target, false, false);
      renderHeight = Math.max(renderHeight, child.height);
    }
    if (row.stack) {
      stack = stackHeightWidth(row.stack);
      renderHeight = Math.max(renderHeight, stack.height);
    }

    const isLast = index === block.rows.length - 1;
    const nextIsStatement =
      block.rows[index + 1] && block.rows[index + 1].type === 'statement';
    if (isLast) renderHeight--;
    else if (row.type === 'value' && nextIsStatement) renderHeight--;

    let height = renderHeight;
    // "The first row gets shifted to accommodate any icons."
    let fieldWidth = index === 0 ? iconWidth : 0;
    let previousEditable = false;
    const seps = [];
    row.fields.forEach((field, position) => {
      if (position !== 0) fieldWidth += SEP_SPACE_X;
      const sep = previousEditable && field.editable ? SEP_SPACE_X : 0;
      seps.push(sep);
      fieldWidth += field.width + sep;
      height = Math.max(height, field.height || FIELD_HEIGHT);
      previousEditable = field.editable;
    });

    if (row.type === 'statement') {
      hasStatement = true;
      fieldStatementWidth = Math.max(fieldStatementWidth, fieldWidth);
    } else if (row.type === 'value') {
      hasValue = true;
      fieldValueWidth = Math.max(fieldValueWidth, fieldWidth);
    } else {
      hasDummy = true;
      fieldValueWidth = Math.max(fieldValueWidth, fieldWidth);
    }

    return { ...row, height, fieldWidth, seps, child, stack };
  });

  const statementEdge = 2 * SEP_SPACE_X + fieldStatementWidth;
  if (hasStatement) rightEdge = Math.max(rightEdge, statementEdge + NOTCH_WIDTH);
  if (hasValue) {
    rightEdge = Math.max(rightEdge, fieldValueWidth + SEP_SPACE_X * 2 + TAB_WIDTH);
  } else if (hasDummy) {
    rightEdge = Math.max(rightEdge, fieldValueWidth + SEP_SPACE_X * 2);
  }

  // --- renderDraw_ -------------------------------------------------------

  const squareTopLeft = conn.output || (conn.previous && connectedAbove);
  const squareBottomLeft = conn.output || (conn.next && connectedBelow);
  const steps = [];

  if (squareTopLeft) steps.push('m 0,0');
  else steps.push(TOP_LEFT_CORNER_START, TOP_LEFT_CORNER);
  if (conn.previous) {
    steps.push('H', NOTCH_WIDTH - 15);
    steps.push(NOTCH_PATH_LEFT);
  }
  steps.push('H', rightEdge);

  let width = rightEdge;
  let cursorY = 0;
  rows.forEach((row, index) => {
    if (row.type === 'statement' && index === 0) {
      steps.push('v', SEP_SPACE_Y);
      cursorY += SEP_SPACE_Y;
    }
    if (row.type === 'value') {
      steps.push(TAB_PATH_DOWN_INNER);
      steps.push('v', row.height - TAB_HEIGHT);
      if (row.child) {
        width = Math.max(width, rightEdge + row.child.width - TAB_WIDTH + 1);
      }
    } else if (row.type === 'statement') {
      steps.push('H', statementEdge + NOTCH_WIDTH + 1);
      steps.push(INNER_TOP_LEFT_CORNER);
      steps.push('v', row.height - 2 * CORNER_RADIUS);
      steps.push(INNER_BOTTOM_LEFT_CORNER);
      steps.push('H', rightEdge);
      if (row.stack) width = Math.max(width, statementEdge + row.stack.width);
    } else {
      steps.push('v', row.height);
    }
    cursorY += row.height;
    const nextIsStatement = rows[index + 1] && rows[index + 1].type === 'statement';
    if (row.type === 'statement' && (index === rows.length - 1 || nextIsStatement)) {
      steps.push('v', SEP_SPACE_Y);
      cursorY += SEP_SPACE_Y;
    }
  });

  if (conn.next) steps.push('H', NOTCH_WIDTH + ' ' + NOTCH_PATH_RIGHT);
  if (squareBottomLeft) steps.push('H 0');
  else {
    steps.push('H', CORNER_RADIUS);
    steps.push('a', CORNER_RADIUS + ',' + CORNER_RADIUS + ' 0 0,1 -' + CORNER_RADIUS + ',-' + CORNER_RADIUS);
  }

  const typedOutput = conn.output && block.check;
  if (conn.output) {
    steps.push('V', TAB_HEIGHT);
    if (!block.check) steps.push(TAB_PATH_DOWN_OUTER);
    else width += TAB_WIDTH;
  }
  steps.push('z');

  let height = cursorY + 1;
  if (conn.next) height += 4;

  return {
    rightEdge,
    statementEdge,
    bottom: cursorY,
    height,
    width,
    d: steps.join(' '),
    typedOutput: Boolean(typedOutput),
  };
}

const output = {};
for (const testCase of fixtures.cases) {
  const build = BLOCKS[testCase.id];
  if (!build) continue;
  const block = build();
  const result = render(block, false, false);
  output[testCase.id] = {
    rightEdge: result.rightEdge,
    statementEdge: result.statementEdge,
    bottom: result.bottom,
    width: result.width,
    d: result.d,
  };
}

process.stdout.write(JSON.stringify(output, null, 2) + '\n');
