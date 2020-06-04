TLuaTreeNode = class(TTreeNode)
  private
    FOwner: TTreeNodes;   // the object, which contains all nodes of the tree
    FCapacity: integer;   // size of FItems
    FCount: integer;      // # of first level children in FItems
    FData: Pointer;       // custom data
    FHeight: integer;     // height in pixels
    FIndex: integer;      // index in parent
    FItems: TTreeNodeArray;  // first level child nodes
    FNextBrother: TTreeNode; // next sibling
    FNextMultiSelected: TTreeNode;
    FOverlayIndex: Integer;
    FParent: TTreeNode;
    FPrevBrother: TTreeNode; // previous sibling
    FPrevMultiSelected: TTreeNode;
    FSelectedIndex: Integer;
    FStateIndex: Integer;
    FStates: TNodeStates;
    FSubTreeCount: integer;// total of all child nodes and self
    FText: string;
    FTop: integer;        // top coordinate
  published
    property Count: Integer read GetCount;
    property Cut: Boolean read GetCut write SetCut;
    property Data: Pointer read FData write SetData;
    property Deleting: Boolean read GetDeleting;
    property DropTarget: Boolean read GetDropTarget write SetDropTarget;
    property Expanded: Boolean read GetExpanded write SetExpanded;
    property Focused: Boolean read GetFocused write SetFocused;
    property Handle: THandle read GetHandle;
    property HasChildren: Boolean read GetHasChildren write SetHasChildren;
    property Height: integer read GetHeight write SetHeight;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property Index: Integer read GetIndex write SetIndex;
    property IsFullHeightVisible: Boolean read IsNodeHeightFullVisible;
    property IsVisible: Boolean read IsNodeVisible;
    property Items[ItemIndex: Integer]: TTreeNode read GetItems write SetItems; default;
    property Level: Integer read GetLevel;
    property MultiSelected: Boolean read GetMultiSelected write SetMultiSelected;
    property NodeEffect: TGraphicsDrawEffect read FNodeEffect write SetImageEffect;
    property OverlayIndex: Integer read FOverlayIndex write SetOverlayIndex default -1;
    property Owner: TTreeNodes read FOwner;
    property Parent: TTreeNode read FParent;
    property Selected: Boolean read GetSelected write SetSelected;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex default -1;
    property StateIndex: Integer read FStateIndex write SetStateIndex default -1;
    property SubTreeCount: integer read FSubTreeCount;
    property Text: string read FText write SetText;
    property Top: integer read GetTop;
    property TreeNodes: TTreeNodes read GetTreeNodes;
    property TreeView: TCustomTreeView read GetTreeView;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;    
