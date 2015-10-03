#C\# ListView VirtualMode Selection Fix

2010-10-10

<!--- tags: csharp gdi -->

When using .NET 2.0 `System.Windows.Forms.ListView` in *virtual* mode, with `ViewType` set to `LargetImage`, then *SHIFT key + mouse selection* is often wrong. Selected indexes include at times more items that user selected with mouse. I did not find any ready solution for this problem around - only people that complain about different funny behavior with `VirtualItemsSelectionRangeChanged`. Code below seems to work, at least for me with .NET 2.0.

```
public class FixedVirtualListView : System.Windows.Forms.ListView
{
  private bool shiftOn = false;
  private int lastItemIndexClicked1 = -1;
  private int lastItemIndexClicked2 = -1;
  protected override void OnKeyDown(KeyEventArgs e)
  {
      shiftOn = e.Shift;
      base.OnKeyDown(e);
  }

  protected override void OnKeyUp(KeyEventArgs e)
  {
      shiftOn = false;
      base.OnKeyUp(e);
  }

  protected override void OnMouseDown(MouseEventArgs e)
  {
      ListViewItem it = this.GetItemAt(e.X, e.Y);
      if (it == null)
      {
      	//lastItemIndexClicked2 = -1;
      }
      else
      {
      	lastItemIndexClicked2 = it.Index;
      }
      if (!shiftOn || (lastItemIndexClicked1 < 0))
      {
      	lastItemIndexClicked1 = lastItemIndexClicked2;
      }
      base.OnMouseDown(e);
  }

  protected override void OnVirtualItemsSelectionRangeChanged(
    ListViewVirtualItemsSelectionRangeChangedEventArgs e)
  {
      try
      {
          int start = lastItemIndexClicked1;
          int end = lastItemIndexClicked2;
          if (end < start)
          {
              int temp = start;
              start = end;
              end = temp;
          }
          if ((start >= 0) && (end >= 0)) 
          {
              ArrayList toRemove = new ArrayList();
              foreach (int index in this.SelectedIndices) 
              {
                  if ((index < start) || (index > end)) toRemove.Add(index);
              }
              if (toRemove.Count > 0) 
              {
                  foreach (int index in toRemove) 
                  {
                      this.SelectedIndices.Remove(index);
                  }
              }
          }
          ListViewVirtualItemsSelectionRangeChangedEventArgs te = 
              new ListViewVirtualItemsSelectionRangeChangedEventArgs(start,
                end, e.IsSelected);
          base.OnVirtualItemsSelectionRangeChanged(te);
      }
      catch
      {
          
      }
  }

}
```

<ins class='nfooter'><a id='fprev' href='#blog/2010/2010-11-01-Finding-POIs-along-a-Route.md'>Finding POIs along a Route</a> <a id='fnext' href='#blog/2010/2010-09-20-Encrypting-IE-Temporary-Files-Folder.md'>Encrypting IE Temporary Files Folder</a></ins>
