// SPDX-License-Identifier: Apache-2.0
package org.fpsot.site;

import org.asciidoctor.Asciidoctor;
import org.asciidoctor.jruby.extension.spi.ExtensionRegistry;
import org.asciidoctor.jruby.internal.JRubyRuntimeContext;

/**
 * Compiles every Rouge lexer once, when AsciidoctorJ starts and before any page is
 * rendered.
 *
 * <p>Rouge 3 compiles a lexer's states the first time they are used and caches them
 * on the lexer class, without a lock. The site renders pages on several threads, and
 * JRuby threads run in parallel, so two pages that colour the same language at the
 * same time can build one state twice: the code then comes out as error tokens, or the
 * render fails. Compiling all states up front leaves nothing to build later.
 */
public class RougeWarmup implements ExtensionRegistry {

    static final String SCRIPT = String.join("\n",
            "require 'rouge'",
            "Rouge::Lexer.all.each do |lexer|",
            "  next unless lexer.respond_to?(:state_definitions)",
            "  names = []",
            "  klass = lexer",
            "  while klass.respond_to?(:state_definitions)",
            "    names.concat(klass.state_definitions.keys)",
            "    klass = klass.superclass",
            "  end",
            "  begin",
            "    names.uniq.each { |name| lexer.get_state(name) }",
            "  rescue StandardError",
            "    # A few lexers in this Rouge version refer to token types that do not",
            "    # exist. They fail the same way when a page uses them, so skip them here.",
            "  end",
            "end");

    @Override
    public void register(Asciidoctor asciidoctor) {
        JRubyRuntimeContext.get(asciidoctor).evalScriptlet(SCRIPT);
    }
}
