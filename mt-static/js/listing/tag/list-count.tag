<list-count>
  <div class="text-right">
    { store.count == 0 ? 0 : (store.page == 1 ? 1 : (store.limit * (store.page-1) + 1)) }
    -
    { (store.limit * store.page) > store.count ? store.count : (store.limit * store.page) }
    /
    { store.count }
  </div>
  <script>
    this.mixin('listTop')
  </script>
</list-count>

