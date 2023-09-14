## Generates all files for the given translation
list='localization_de.arb localization_en.arb localization_es.arb localization_pt.arb'

#base command translations
for i in $list; do
flutter gen-l10n --arb-dir=translations --template-arb-file=$i --output-localization-file=trufi_app_localizations.dart --output-class=TrufiAppLocalization --output-dir=lib/translations --no-synthetic-package
done
