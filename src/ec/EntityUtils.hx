package ec;
import ec.Entity;
using ec.EntityUtils;
class EntityUtils {
    public static function showTree<T>(e:Entity, c:Class<T> = null, lvl = 0) {
        var content = c == null ? "" + e.getComponents() : "" + e.getComponent(c);
        trace([for (i in 0...lvl) "="].join("") + e.name + " ===" + content);
        for (ch in e.getChildren())
            showTree(ch, c, lvl + 1);
    }
}
