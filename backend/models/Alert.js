const mongoose = require('mongoose');

const SEVERITY = { emergency: 3, warning: 2, info: 1 };

// Display alerts are stored durably so a restart neither loses an active alert
// nor reports it as cleared. Clearing keeps the record; nothing is deleted.
const alertSchema = new mongoose.Schema(
  {
    message: { type: String, required: true, trim: true, maxlength: 4000 },
    type: { type: String, required: true, enum: Object.keys(SEVERITY) },
    scope: { type: String, required: true, enum: ['all', 'selected'] },
    targets: {
      type: [String],
      default: [],
      validate: {
        validator(targets) {
          return this.scope === 'all' ? targets.length === 0 : targets.length > 0;
        },
        message: 'A selected-scope alert needs at least one target; an all-scope alert takes none.',
      },
    },
    active: { type: Boolean, default: true, index: true },
    issuedAt: { type: Date, default: Date.now },
    expiresAt: { type: Date },
    clearedAt: { type: Date },
    clearedReason: { type: String, trim: true, maxlength: 500 },
  },
  { timestamps: true },
);

alertSchema.statics.SEVERITY = SEVERITY;

alertSchema.methods.toDisplay = function toDisplay() {
  return {
    id: this._id.toString(),
    active: this.active,
    message: this.message,
    type: this.type,
    scope: this.scope,
    targets: this.scope === 'selected' ? this.targets : undefined,
    timestamp: this.issuedAt,
    expiresAt: this.expiresAt,
  };
};

module.exports = mongoose.model('Alert', alertSchema);
