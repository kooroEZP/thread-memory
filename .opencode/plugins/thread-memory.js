import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, '../..');
const skillsDir = path.join(rootDir, 'skills');
const skillPath = path.join(skillsDir, 'thread-memory', 'SKILL.md');

let cachedBootstrap = undefined;

const stripFrontmatter = (content) => {
  const match = content.match(/^---\n[\s\S]*?\n---\n([\s\S]*)$/);
  return match ? match[1].trim() : content.trim();
};

const getBootstrap = () => {
  if (cachedBootstrap !== undefined) return cachedBootstrap;
  if (!fs.existsSync(skillPath)) {
    cachedBootstrap = null;
    return cachedBootstrap;
  }

  const body = stripFrontmatter(fs.readFileSync(skillPath, 'utf8'));
  cachedBootstrap = `<THREAD_MEMORY_INSTRUCTIONS>
The thread-memory skill is available and should be used for substantive work.

${body}
</THREAD_MEMORY_INSTRUCTIONS>`;
  return cachedBootstrap;
};

export const ThreadMemoryPlugin = async () => {
  return {
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir);
      }
    },

    'experimental.chat.messages.transform': async (_input, output) => {
      const bootstrap = getBootstrap();
      if (!bootstrap || !output.messages.length) return;

      const firstUser = output.messages.find((message) => message.info.role === 'user');
      if (!firstUser || !firstUser.parts.length) return;

      const alreadyInjected = firstUser.parts.some(
        (part) => part.type === 'text' && part.text.includes('THREAD_MEMORY_INSTRUCTIONS'),
      );
      if (alreadyInjected) return;

      const referencePart = firstUser.parts[0];
      firstUser.parts.unshift({ ...referencePart, type: 'text', text: bootstrap });
    },
  };
};
