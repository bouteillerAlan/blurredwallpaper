interface TasksModelItem {
  // Basic properties
  objectName: string;
  index: number;
  row: number;
  column: number;
  hasModelChildren: boolean;
  ChildCount: number;

  // Window state properties
  IsActive: boolean;
  IsWindow: boolean;
  IsMinimized: boolean;
  IsMaximized: boolean;
  IsFullScreen: boolean;
  IsShaded: boolean;
  IsHidden: boolean;
  IsDemandingAttention: boolean;

  // Window capabilities
  IsClosable: boolean;
  IsMinimizable: boolean;
  IsMaximizable: boolean;
  IsMovable: boolean;
  IsResizable: boolean;
  IsFullScreenable: boolean;
  IsShadeable: boolean;

  // Window position properties
  StackingOrder: number;
  Geometry: string; // QRect representation
  ScreenGeometry: string; // QRect representation

  // Window stacking properties
  IsKeepAbove: boolean;
  IsKeepBelow: boolean;

  // Desktop/activity related
  IsOnAllVirtualDesktops: boolean;
  VirtualDesktops: string;
  IsVirtualDesktopsChangeable: boolean;
  Activities: string;

  // Application properties
  AppName: string;
  AppId: string;
  AppPid: number;
  GenericName: string;

  // Launcher properties
  IsLauncher: boolean;
  HasLauncher: boolean;
  LauncherUrl: string;
  LauncherUrlWithoutIcon: string;
  CanLaunchNewInstance: boolean;
  IsStartup: boolean;

  // Grouping properties
  IsGroupable: boolean;
  IsGroupParent: boolean;

  // Taskbar/panel behavior
  SkipTaskbar: boolean;
  SkipPager: boolean;

  // Drag & drop properties
  MimeType: string;
  MimeData: string;
  WinIdList: string;

  // UI metadata
  display: string;  // window title
  decoration: string;
  LastActivated: string;
  windowTypes: any;  // Added based on your code

  // Menu properties
  ApplicationMenuServiceName: string;
  ApplicationMenuObjectPath: string;

  // Optional UI properties
  toolTip?: string;
  statusTip?: undefined;
  whatsThis?: undefined;
  edit?: undefined;
}
