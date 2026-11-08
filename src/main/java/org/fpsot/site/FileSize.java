// SPDX-License-Identifier: Apache-2.0
package org.fpsot.site;

import io.quarkus.qute.TemplateExtension;

/**
 * Writes a file size for a download link, in the page's language: {@code {size:of(bytes, lang)}}.
 *
 * <p>Sizes are in kilobytes (KB, Ko) below one megabyte, rounded to a whole number, and
 * in megabytes (MB, Mo) above, with one decimal: "412 KB", "3.4 MB" in English, and
 * "412 Ko", "3,4 Mo" in French. One kilobyte is 1,000 bytes. A space that does not
 * break separates the number from its unit, as the OQLF asks, so the two stay on one
 * line in both languages.
 */
@TemplateExtension(namespace = "size")
public class FileSize {

    static final char NBSP = ' ';

    /** Returns the size of {@code bytes} for a page in {@code lang} ("en" or "fr"), or "" when it is not a number. */
    static String of(Object bytes, String lang) {
        long n;
        try {
            n = Long.parseLong(String.valueOf(bytes).trim());
        } catch (NumberFormatException e) {
            return "";
        }
        boolean fr = "fr".equals(lang);
        if (n < 999_500) {
            return Math.max(1, Math.round(n / 1000.0)) + "" + NBSP + (fr ? "Ko" : "KB");
        }
        long tenths = Math.round(n / 100_000.0);
        String number = (tenths / 10) + (fr ? "," : ".") + (tenths % 10);
        return number + NBSP + (fr ? "Mo" : "MB");
    }
}
