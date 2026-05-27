export type AutomationStepType =
  | 'open_url'
  | 'click'
  | 'type'
  | 'wait'
  | 'scroll'
  | 'screenshot';

export interface AutomationStepBase {
  id: string;
  type: AutomationStepType;
  description?: string;
}

export interface OpenUrlStep extends AutomationStepBase {
  type: 'open_url';
  url: string;
}

export interface ClickStep extends AutomationStepBase {
  type: 'click';
  selector: string;
}

export interface TypeStep extends AutomationStepBase {
  type: 'type';
  selector: string;
  text: string;
  delayMs?: number;
}

export interface WaitStep extends AutomationStepBase {
  type: 'wait';
  ms?: number;
  untilSelectorVisible?: string;
}

export interface ScrollStep extends AutomationStepBase {
  type: 'scroll';
  x?: number;
  y?: number;
  toSelector?: string;
}

export interface ScreenshotStep extends AutomationStepBase {
  type: 'screenshot';
  fileName?: string;
  fullPage?: boolean;
}

export type AutomationStep =
  | OpenUrlStep
  | ClickStep
  | TypeStep
  | WaitStep
  | ScrollStep
  | ScreenshotStep;

export interface AutomationScript {
  id: string;
  name: string;
  description?: string;
  steps: AutomationStep[];
  createdAt: string;
  updatedAt: string;
}

export type AutomationRunStatus =
  | 'queued'
  | 'running'
  | 'completed'
  | 'failed';

export interface AutomationRun {
  id: string;
  scriptId: string;
  profileId: string;
  status: AutomationRunStatus;
  startedAt?: string;
  finishedAt?: string;
  errorMessage?: string;
}

