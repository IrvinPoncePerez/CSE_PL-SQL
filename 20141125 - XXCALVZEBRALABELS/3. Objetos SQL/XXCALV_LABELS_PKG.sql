PACKAGE XXCALV_LABELS_PKG IS
  procedure label_header(event in varchar2);
  procedure label_lines(event in varchar2);
  procedure process_label;
  procedure cancel_label;
  procedure issue_label;
  procedure print_zebra_label;
  procedure to_floor_label;
END XXCALV_LABELS_PKG;