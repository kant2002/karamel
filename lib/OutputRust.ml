(* Actually printing out Rust *)

open PPrint

let rust_name f = f ^ ".rs"

let write_file file =
  let prefix, decls = file in
  if decls <> [] then
    (* TODO: directory structure according to the prefix *)
    let dirs, filename = KList.split_at_last prefix in
    let base = if !Options.tmpdir <> "" then !Options.tmpdir else "." in
    let dirs = List.fold_left Driver.((^^)) base dirs in
    Driver.mkdirp dirs;
    let filename = Driver.((^^)) dirs (rust_name filename) in
    Utils.with_open_out_bin filename (fun oc ->
      let doc = separate_map (hardline ^^ hardline) (PrintMiniRust.print_decl prefix) decls ^^ hardline in
      PPrint.ToChannel.pretty 0.95 100 oc doc
    )

let write_all files =
  Driver.maybe_create_output_dir ();
  List.iter write_file files;
  if !PrintMiniRust.failures > 0 then
    KPrint.bprintf "%s%d total printing errors%s\n" Ansi.red !PrintMiniRust.failures Ansi.reset
