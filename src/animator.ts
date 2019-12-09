type AnimationState = Idle | Transitioning;

interface Idle {
  kind: "idle";
  content: HTMLElement;
}
interface Transitioning {
  kind: "transitioning";
  content: HTMLElement;
  to: HTMLElement;
}

class AnimatorFrom extends HTMLElement {
  constructor() {
    super();
  }
}

class Animator extends HTMLElement {
  animationState: AnimationState;

  constructor() {
    super();
  }

  connectedCallback() {
    this.updateState(this.getAttribute("elm-animator-state"));
  }

  static get observedAttributes() {
    return ["elm-animator-state"];
  }

  getContent(): HTMLElement {
    return this.getElementsByTagName("elm-animator-content")[0] as HTMLElement;
  }

  updateState(state: String) {
    switch (state) {
      case "transitioning":
        const to = this.getContent();
        this.animationState = {
          ...this.animationState,
          kind: "transitioning",
          to
        };
        break;
      case "idle":
      default:
        const content = this.getContent().cloneNode(true) as HTMLElement;
        this.animationState = { kind: "idle", content };
        break;
    }
  }

  attributeChangedCallback(name: string, oldValue: string, newValue: string) {
    switch (name) {
      case "elm-animator-state":
        this.updateState(newValue);
        if (this.animationState.kind == "transitioning") {
          this.transitioning();
        }
        break;

      default:
        break;
    }
  }

  transitioning() {
    const kind = this.getAttribute("elm-animator-kind");

    const from = new AnimatorFrom();
    const to = this.getContent();

    from.appendChild(this.animationState.content);
    this.insertBefore(from, to);

    from.style.display = "inline-block";
    to.style.display = "inline-block";

    switch (kind) {
      case "SlideInFromTop":
        this.slideInFromTop(from, to);
        break;

      case "Fade":
        this.fade(from, to);
        break;

      default:
        break;
    }
  }

  slideInFromTop(from: HTMLElement, to: HTMLElement) {
    const duration = 500;
    const options: KeyframeAnimationOptions = {
      duration,
      iterations: 1,
      fill: "forwards",
      easing: "ease-in-out"
    };

    from.animate(
      [{ transform: "translateY(-100%)" }, { transform: "translateY(0%)" }],
      options
    );

    to.animate(
      [{ transform: "translateY(-100%)" }, { transform: "translateY(0%)" }],
      options
    ).addEventListener("finish", () => {
      this.dispatchEvent(new Event("finish"));
    });
  }

  fade(from: HTMLElement, to: HTMLElement) {
    console.log("fade");

    const duration = 500;
    const options: KeyframeAnimationOptions = {
      duration,
      iterations: 1,
      fill: "forwards",
      easing: "ease-in-out"
    };

    from.animate([{ opacity: "1" }, { opacity: "0" }], options);

    to.animate([{ opacity: "0" }, { opacity: "1" }], options).addEventListener(
      "finish",
      () => {
        this.removeChild(from);
        this.dispatchEvent(new Event("elmAnimatorFinish"));
      }
    );
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  customElements.define("elm-animator", Animator);
  customElements.define("elm-animator-from", AnimatorFrom);
});
