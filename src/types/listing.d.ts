export interface ButtonAction extends ListAction {}

export interface ButtonActions {
  [key: string]: ButtonAction;
}

export interface Filter {
  can_delete?: number;
  can_edit: number;
  can_save: number;
  id: string;
  items: Array<Item>;
  label: string;
  order?: number;
}

interface FilterType {
  baseType: string;
  field: string;
  label: string;
  type: string;

  editable?: boolean;
  singleton?: boolean;
}

interface Item {
  args: object;
  type: string;
}

export interface ListAction {
  type: string;

  continue_prompt?: string;
  dialog?: number;
  input?: string;
  js?: string;
  js_message?: string;
  label?: string;
  max?: string;
  min?: string;
  mobile?: boolean;
  mode?: string;
  no_prompt?: string;
  xhr?: boolean;
}

export interface ListActionClient {
  generateRequestData: (obj: object) => object;
  post: (obj: object) => void;
  removeFilterKeyFromReturnArgs: () => string;
  removeFilterItemFromReturnArgs: () => string;
}

export interface ListActions {
  [key: string]: ListAction;
}

interface ListColumn {
  checked: number;
  col_class: string;
  default_sort_order: string;
  display: number;
  force_display: number;
  id: string;
  is_default: number;
  label: string;
  order: string;
  primary: number;
  sortable: number;
  sorted: number;
  sub_fields: Array<SubField>;
  type: string;
}

interface ListData {
  DefaultPage: number;

  allpassFilter: Filter;
  checkedAllRows: boolean;
  checkedAllRowsOnPage: boolean;
  columns: Array<ListColumn>;
  count: number | null;
  currentFilter: Filter;
  disableUserDispOption: boolean;
  filters: Array<Filter>;
  isLoading: boolean;
  limit: number | null;
  objectType: string;
  objects: Array<ListObject> | null;
  page: number | null;
  pageMax: number;
  showColumns: Array<ListColumn>;
  sortBy: string;
  sortOrder: string;

  addFilterItem: () => void;
  addFilterItemContent: (itemIndex: string, contentIndex: number) => void;
  checkAllRows: () => void;
  clickRow: () => void;
  createNewFilter: (filterLabel: string) => void;
  getCheckedRowCount: () => number;
  getColumn: (columnId: number) => void;
  getCheckedColumnIds: () => Array<string>;
  getCheckedRowIds: () => Array<string>;
  getFilter: (filterId: string) => Filter | null;
  getListEnd: () => number;
  getListStart: () => number;
  getMobileColumnIndex: () => number;
  getNewFilterLabel: (objectLabel: string) => string;
  getSubField: (subFieldId: string) => SubField;
  hasMobileColumn: () => boolean;
  hasSystemFilter: () => boolean;
  isCheckedAllRowsOnPage: () => boolean;
  isFilterItemSelected: (type: string) => boolean;
  movePage: (page: number) => boolean;
  removeFilterItemByIndex: (itemIndex: string) => void;
  removeFilterItemContent: (itemIndex: string, contentIndex: string) => void;
  resetAllClickedRows: () => void;
  setFilter: (filter: Filter) => boolean;
  setFilterById: (filterId: string) => void | boolean;
  setDeleteFilterResult: (result: Result) => void;
  setResult: (result: Result) => void;
  setSaveFilterResult: (result: Result) => void;
  toggleAllRowsOnPage: () => void;
  toggleColumn: (columnId: string) => void;
  toggleRow: (rowIndex: string) => void;
  toggleSortColumn: (columnId: string) => void;
  toggleSubField: (subFieldId: string) => void;
  resetColumns: () => void;
  updateAllRowsOnPage: (nextState: boolean) => void;
  updateIsLoading: (nextState: boolean) => void;
  updateLimit: (limit: number) => void;
}

export interface ListObject {
  checked: number;
  clicked: boolean;
  object: Array<object>;
}

export interface ListStore extends ListData {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  on: (event: string, fn: (...args: any) => void) => void;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  trigger: (event: string, ...args: any) => void;
}

export interface MoreListAction extends ListAction {}

export interface MoreListActions {
  [key: string]: MoreListAction;
}

interface Result {
  columns: Array<ListColumn>;
  count: number;
  editable_count: number;
  filters: Array<Filter>;
  objects: Array<ListObject>;
  page_max: number;
}

interface SubField {
  class: string;
  checked: number;
  display: number;
  id: string;
  is_default: number;
  label: string;
  parent_id: string;
}
