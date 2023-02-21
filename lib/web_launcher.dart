import 'package:universal_html/html.dart' show window;

void launch(url, {newTab}) async {
  newTab = newTab ?? true;
  if (newTab)
    await window.open(url, "");
  else  window.location.href = url;
}

