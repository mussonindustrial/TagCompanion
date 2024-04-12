#Requires AutoHotkey v2.0

class NamedValues {

    values := Map()

    class NamedValue {
        __New(name, valueProvider) {
            this.name := name
            this.valueProvider := valueProvider
        }

        Get() {
            if (this.valueProvider is String) {
                return this.valueProvider
            } else if (this.valueProvider is Func) {
                return this.valueProvider()
            }
        }
    }

    Set(name, valueProvider) {
        this.values[name] := NamedValues.NamedValue(name, valueProvider)
    }


    Get(name) {
        if (this.values[name]) {
            return this.values[name].Get()
        }
    }

    ApplyTo(haystack) {
        s := haystack
        for k, v in this.values {
            s := StrReplace(s, "${" v.name "}", v.Get())
        }
        return s
    }
}