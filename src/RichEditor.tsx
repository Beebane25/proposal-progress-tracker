import { useRef, useEffect, useState } from 'react';
import { Bold, Italic, Underline, Strikethrough, AlignLeft, AlignCenter, AlignRight, AlignJustify, List, ListOrdered, Link2, Type, Palette, Highlighter, ChevronDown, Undo2, Redo2, Heading1, Heading2, Heading3, IndentIncrease, IndentDecrease, Quote, Code, Pilcrow } from 'lucide-react';

type RichEditorProps = {
  value: string;
  onChange: (html: string) => void;
  placeholder?: string;
};

const FONT_FAMILIES = ['Arial', 'Times New Roman', 'Courier New', 'Georgia', 'Verdana', 'Tahoma'];
const FONT_SIZES = ['10px', '12px', '14px', '16px', '18px', '20px', '24px', '28px'];
const COLORS = ['#1a1a1a', '#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c', '#95a5a6'];
const HIGHLIGHTS = ['#ffff00', '#a8e6cf', '#ffd3b6', '#b3d9ff', '#ffb3c1', '#d9b3ff', '#ffffff'];

type BlockStyle = { label: string; tag: string; icon: React.ReactNode; className?: string };

const STYLES: BlockStyle[] = [
  { label: 'Teks normal', tag: 'p', icon: <Pilcrow size={15} /> },
  { label: 'Judul 1', tag: 'h1', icon: <Heading1 size={15} /> },
  { label: 'Judul 2', tag: 'h2', icon: <Heading2 size={15} /> },
  { label: 'Judul 3', tag: 'h3', icon: <Heading3 size={15} /> },
  { label: 'Kutipan', tag: 'blockquote', icon: <Quote size={15} /> },
  { label: 'Kode', tag: 'pre', icon: <Code size={15} /> },
];

function sanitizeHtml(html: string): string {
  const temp = document.createElement('div');
  temp.innerHTML = html;
  temp.querySelectorAll('script, iframe, object, embed, style, link, meta').forEach(el => el.remove());
  temp.querySelectorAll('*').forEach(el => {
    Array.from(el.attributes).forEach(attr => {
      if (attr.name.toLowerCase().startsWith('on') || attr.name === 'srcdoc') el.removeAttribute(attr.name);
    });
  });
  return temp.innerHTML;
}

function normalize(html: string): string {
  const clean = sanitizeHtml(html || '');
  const textOnly = clean.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim();
  if (!textOnly) return '';
  // Plain text / inline-only markup -> wrap in a paragraph so blocks behave like Word.
  if (!/<(p|div|h[1-6]|ul|ol|blockquote|pre|li)\b/i.test(clean)) {
    return `<p>${clean}</p>`;
  }
  return clean;
}

function wrapSelection(tagName: string, attrs: Record<string, string>): void {
  const sel = window.getSelection();
  if (!sel || sel.rangeCount === 0 || sel.isCollapsed) return;
  const range = sel.getRangeAt(0);
  const el = document.createElement(tagName);
  for (const [k, v] of Object.entries(attrs)) el.setAttribute(k, v);
  try {
    range.surroundContents(el);
  } catch {
    const frag = range.extractContents();
    el.appendChild(frag);
    range.insertNode(el);
  }
  sel.removeAllRanges();
  sel.addRange(range);
}

export function RichEditor({ value, onChange, placeholder }: RichEditorProps) {
  const editorRef = useRef<HTMLDivElement>(null);
  const lastEmittedRef = useRef(value);
  const [showFontMenu, setShowFontMenu] = useState(false);
  const [showSizeMenu, setShowSizeMenu] = useState(false);
  const [showStyleMenu, setShowStyleMenu] = useState(false);
  const [showColorMenu, setShowColorMenu] = useState(false);
  const [showHighlightMenu, setShowHighlightMenu] = useState(false);
  const [currentFont, setCurrentFont] = useState('Arial');
  const [currentSize, setCurrentSize] = useState('14px');

  // Seed DOM once on mount.
  useEffect(() => {
    const el = editorRef.current;
    if (!el) return;
    el.innerHTML = normalize(value);
    el.classList.toggle('is-empty', el.textContent!.trim() === '');
    lastEmittedRef.current = value;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Sync DOM when the value changes externally (e.g. user switched chapter),
  // without clobbering the cursor during normal typing.
  useEffect(() => {
    const el = editorRef.current;
    if (!el || value === lastEmittedRef.current) return;
    lastEmittedRef.current = value;
    el.innerHTML = normalize(value);
    el.classList.toggle('is-empty', el.textContent!.trim() === '');
  }, [value]);

  const emit = () => {
    const el = editorRef.current;
    if (!el) return;
    const html = sanitizeHtml(el.innerHTML);
    const empty = el.textContent!.trim() === '';
    el.classList.toggle('is-empty', empty);
    const next = empty ? '' : html;
    lastEmittedRef.current = next;
    onChange(next);
  };

  const exec = (cmd: string, val?: string) => {
    document.execCommand(cmd, false, val);
    editorRef.current?.focus();
    emit();
  };

  const insertLink = () => {
    const url = window.prompt('Masukkan URL:');
    if (url) exec('createLink', url.trim());
  };

  const applyFont = (font: string) => {
    exec('fontName', font);
    setCurrentFont(font);
    setShowFontMenu(false);
  };

  const applySize = (size: string) => {
    wrapSelection('span', { style: `font-size:${size}` });
    setCurrentSize(size);
    setShowSizeMenu(false);
    emit();
  };

  const applyBlock = (tag: string) => {
    exec('formatBlock', tag === 'pre' ? 'pre' : tag);
    setShowStyleMenu(false);
  };

  const applyColor = (color: string) => {
    exec('foreColor', color);
    setShowColorMenu(false);
  };

  const applyHighlight = (color: string) => {
    exec('backColor', color);
    setShowHighlightMenu(false);
  };

  return (
    <div className="rich-editor">
      <div className="ribbon-toolbar">
        {/* Clipboard */}
        <div className="ribbon-group">
          <span className="ribbon-label">Clipboard</span>
          <div className="ribbon-buttons">
            <button type="button" onClick={() => exec('undo')} title="Undo (Ctrl+Z)" className="ribbon-btn">
              <Undo2 size={16} />
            </button>
            <button type="button" onClick={() => exec('redo')} title="Redo (Ctrl+Y)" className="ribbon-btn">
              <Redo2 size={16} />
            </button>
          </div>
        </div>

        {/* Font */}
        <div className="ribbon-group">
          <span className="ribbon-label">Font</span>
          <div className="ribbon-buttons">
            <div className="ribbon-dropdown">
              <button type="button" onClick={() => setShowFontMenu(!showFontMenu)} className="ribbon-btn dropdown-trigger">
                <Type size={14} />
                <span style={{ fontSize: 11 }}>{currentFont}</span>
                <ChevronDown size={12} />
              </button>
              {showFontMenu && (
                <div className="ribbon-menu">
                  {FONT_FAMILIES.map(f => (
                    <button key={f} type="button" onClick={() => applyFont(f)} style={{ fontFamily: f }}>
                      {f}
                    </button>
                  ))}
                </div>
              )}
            </div>
            <div className="ribbon-dropdown">
              <button type="button" onClick={() => setShowSizeMenu(!showSizeMenu)} className="ribbon-btn dropdown-trigger">
                <span style={{ fontSize: 11 }}>{currentSize}</span>
                <ChevronDown size={12} />
              </button>
              {showSizeMenu && (
                <div className="ribbon-menu">
                  {FONT_SIZES.map(s => (
                    <button key={s} type="button" onClick={() => applySize(s)}>
                      {s}
                    </button>
                  ))}
                </div>
              )}
            </div>
            <button type="button" onClick={() => exec('bold')} title="Bold (Ctrl+B)" className="ribbon-btn">
              <Bold size={16} />
            </button>
            <button type="button" onClick={() => exec('italic')} title="Italic (Ctrl+I)" className="ribbon-btn">
              <Italic size={16} />
            </button>
            <button type="button" onClick={() => exec('underline')} title="Underline (Ctrl+U)" className="ribbon-btn">
              <Underline size={16} />
            </button>
            <button type="button" onClick={() => exec('strikeThrough')} title="Strikethrough" className="ribbon-btn">
              <Strikethrough size={16} />
            </button>
            <div className="ribbon-dropdown">
              <button type="button" onClick={() => setShowColorMenu(!showColorMenu)} className="ribbon-btn" title="Warna teks">
                <Palette size={16} />
                <ChevronDown size={11} />
              </button>
              {showColorMenu && (
                <div className="ribbon-menu color-grid">
                  {COLORS.map(c => (
                    <button key={c} type="button" onClick={() => applyColor(c)} style={{ background: c }} className="color-swatch" aria-label={`Warna ${c}`} />
                  ))}
                </div>
              )}
            </div>
            <div className="ribbon-dropdown">
              <button type="button" onClick={() => setShowHighlightMenu(!showHighlightMenu)} className="ribbon-btn" title="Highlight">
                <Highlighter size={16} />
                <ChevronDown size={11} />
              </button>
              {showHighlightMenu && (
                <div className="ribbon-menu color-grid">
                  {HIGHLIGHTS.map(c => (
                    <button key={c} type="button" onClick={() => applyHighlight(c)} style={{ background: c }} className="color-swatch" aria-label={`Highlight ${c}`} />
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Paragraph */}
        <div className="ribbon-group">
          <span className="ribbon-label">Paragraph</span>
          <div className="ribbon-buttons">
            <button type="button" onClick={() => exec('justifyLeft')} title="Rata kiri" className="ribbon-btn">
              <AlignLeft size={16} />
            </button>
            <button type="button" onClick={() => exec('justifyCenter')} title="Tengah" className="ribbon-btn">
              <AlignCenter size={16} />
            </button>
            <button type="button" onClick={() => exec('justifyRight')} title="Rata kanan" className="ribbon-btn">
              <AlignRight size={16} />
            </button>
            <button type="button" onClick={() => exec('justifyFull')} title="Rata kiri-kanan" className="ribbon-btn">
              <AlignJustify size={16} />
            </button>
            <button type="button" onClick={() => exec('insertUnorderedList')} title="Daftar berpoin" className="ribbon-btn">
              <List size={16} />
            </button>
            <button type="button" onClick={() => exec('insertOrderedList')} title="Daftar bernomor" className="ribbon-btn">
              <ListOrdered size={16} />
            </button>
            <button type="button" onClick={() => exec('outdent')} title="Kurangi indentasi" className="ribbon-btn">
              <IndentDecrease size={16} />
            </button>
            <button type="button" onClick={() => exec('indent')} title="Tambah indentasi" className="ribbon-btn">
              <IndentIncrease size={16} />
            </button>
          </div>
        </div>

        {/* Styles */}
        <div className="ribbon-group">
          <span className="ribbon-label">Styles</span>
          <div className="ribbon-buttons">
            <div className="ribbon-dropdown">
              <button type="button" onClick={() => setShowStyleMenu(!showStyleMenu)} className="ribbon-btn dropdown-trigger">
                <Pilcrow size={14} />
                <span style={{ fontSize: 11 }}>Gaya</span>
                <ChevronDown size={12} />
              </button>
              {showStyleMenu && (
                <div className="ribbon-menu">
                  {STYLES.map(s => (
                    <button key={s.tag} type="button" onClick={() => applyBlock(s.tag)}>
                      <span className="style-menu-icon">{s.icon}</span> {s.label}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Insert */}
        <div className="ribbon-group">
          <span className="ribbon-label">Insert</span>
          <div className="ribbon-buttons">
            <button type="button" onClick={insertLink} title="Sisipkan tautan" className="ribbon-btn">
              <Link2 size={16} />
            </button>
            <button type="button" onClick={() => exec('removeFormat')} title="Hapus format" className="ribbon-btn">
              Clear
            </button>
          </div>
        </div>
      </div>

      <div
        ref={editorRef}
        contentEditable
        onInput={emit}
        onBlur={emit}
        className="rich-editor-content is-empty"
        data-placeholder={placeholder || 'Mulai menulis…'}
        suppressContentEditableWarning
      />
    </div>
  );
}
